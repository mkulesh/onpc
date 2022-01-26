#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>

#include <memory>

#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window
{
public:
    // Creates a new FlutterWindow hosting a Flutter view running |project|.
    explicit FlutterWindow(const flutter::DartProject& project);
    virtual ~FlutterWindow();

protected:
    // Win32Window:
    bool OnCreate() override;
    void OnDestroy() override;
    LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

private:
    // The project to run.
    flutter::DartProject project_;

    // The Flutter instance hosted by this window.
    std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
    std::unique_ptr<flutter::MethodChannel<>> platform_channel_;
    DWORD lastKeyEvent;

    void InitMethodChannel(flutter::FlutterEngine* flutter_instance);
    int VirtualKeyCodeToString(UINT virtualKey, std::string & out) const;
    void SendKeyCode(const std::string & key) const;

public:
    void ProcessKeyEvent(const KBDLLHOOKSTRUCT * kbdStruct);
    void DartLog(const std::string & log) const;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
