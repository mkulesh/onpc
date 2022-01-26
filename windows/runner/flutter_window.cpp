#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"
#include <flutter/standard_method_codec.h>
#include <flutter/method_result_functions.h>
#include <flutter/encodable_value.h>

static const UINT sysKeys[9] = {VK_LSHIFT, VK_LCONTROL, VK_LWIN, VK_LMENU, VK_RMENU, VK_RWIN, VK_APPS, VK_RCONTROL, VK_RSHIFT};

FlutterWindow::FlutterWindow(const flutter::DartProject& project):
    project_(project),
    lastKeyEvent(0)
{
    // empty
}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate()
{
    if (!Win32Window::OnCreate())
    {
        return false;
    }

    RECT frame = GetClientArea();

    // The size here must match the window dimensions to avoid unnecessary surface
    // creation / destruction in the startup path.
    flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
        frame.right - frame.left, frame.bottom - frame.top, project_);
    // Ensure that basic setup of the controller was successful.
    if (!flutter_controller_->engine() || !flutter_controller_->view())
    {
        return false;
    }
    RegisterPlugins(flutter_controller_->engine());
    InitMethodChannel(flutter_controller_->engine());
    SetChildContent(flutter_controller_->view()->GetNativeWindow());
    return true;
}

void FlutterWindow::OnDestroy()
{
    if (flutter_controller_)
    {
        flutter_controller_ = nullptr;
    }
    if (platform_channel_)
    {
        platform_channel_ = nullptr;
    }
    Win32Window::OnDestroy();
}

LRESULT FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept
{
    // Give Flutter, including plugins, an opportunity to handle window messages.
    if (flutter_controller_)
    {
        std::optional<LRESULT> result =
            flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam, lparam);
        if (result)
        {
            return *result;
        }
    }

    switch (message)
    {
    case WM_FONTCHANGE:
        flutter_controller_->engine()->ReloadSystemFonts();
        break;
    }

    return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::InitMethodChannel(flutter::FlutterEngine* flutter_instance)
{
    const static std::string channel_name("platform_method_channel");

    platform_channel_ = std::make_unique<flutter::MethodChannel<>>(
        flutter_instance->messenger(), channel_name,
        &flutter::StandardMethodCodec::GetInstance());

    platform_channel_->SetMethodCallHandler(
        [](const flutter::MethodCall<>& call,
        std::unique_ptr<flutter::MethodResult<>> result)
        {
            if (call.method_name().compare("test") == 0)
            {
                result->Success("OK");
            }
            else
            {
                result->NotImplemented();
            }
        }
    );
}

int FlutterWindow::VirtualKeyCodeToString(UINT virtualKey, std::string & out) const
{
    UINT scanCode = MapVirtualKey(virtualKey, MAPVK_VK_TO_VSC);
    CHAR szName[128];
    int res = 0;
    switch (virtualKey)
    {
        case VK_LEFT: case VK_UP: case VK_RIGHT: case VK_DOWN:
        case VK_RCONTROL: case VK_RMENU: case VK_LWIN: case VK_RWIN:
        case VK_APPS: case VK_PRIOR: case VK_NEXT: case VK_END:
        case VK_HOME: case VK_INSERT: case VK_DELETE: case VK_DIVIDE: case VK_NUMLOCK:
            scanCode |= KF_EXTENDED;
        default:
            res = GetKeyNameTextA(scanCode << 16, szName, 128);
    }
    if (res > 0)
    {
        out = szName;
    }
    return res;
}

void FlutterWindow::SendKeyCode(const std::string & key) const
{
    if (platform_channel_ && platform_channel_.get() != nullptr)
    {
        platform_channel_.get()->InvokeMethod("shortcut", std::make_unique<flutter::EncodableValue>(key));
    }
}

void FlutterWindow::ProcessKeyEvent(const KBDLLHOOKSTRUCT * kbdStruct)
{
    if (std::labs(lastKeyEvent - kbdStruct->time) < 50)
    {
        return;
    }
    std::string vkName = "";
    if (VirtualKeyCodeToString(kbdStruct->vkCode, vkName) > 0)
    {
        std::string description = "";
        for (UINT sysCode : sysKeys)
        {
            std::string sysName;
            if (GetKeyState(sysCode) < 0 && VirtualKeyCodeToString(sysCode, sysName))
            {
                if (!description.empty())
                {
                    description += " + ";
                }
                description += sysName;
                if (sysCode == kbdStruct->vkCode)
                {
                    vkName = "";
                }
            }
        }
        if (!description.empty() && !vkName.empty())
        {
            description += " + ";
        }
        description += vkName;
        SendKeyCode(description);
    }
    lastKeyEvent = kbdStruct->time;
}

void FlutterWindow::DartLog(const std::string & log) const
{
    if (platform_channel_ && platform_channel_.get() != nullptr)
    {
        platform_channel_.get()->InvokeMethod("log", std::make_unique<flutter::EncodableValue>(log));
    }
}
