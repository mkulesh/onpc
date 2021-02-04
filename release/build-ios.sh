#!/bin/bash

flutter channel stable
flutter doctor
flutter build ios --release
