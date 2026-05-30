# Olcbox KeepAlive iOS Tweak

The tweak is a Theos `dylib` package for jailbroken iOS devices. It loads only into `org.olcbox.app.ios` and starts an infinite silent audio loop as soon as Olcbox is opened, including after the app enters background.

The iOS app already declares `UIBackgroundModes -> audio` in `iosApp/iosApp/Info.plist`, so the tweak uses `AVAudioSessionCategoryPlayback` and `AVAudioPlayer` to keep iOS treating the app as an audio player.

## Build

Install Theos and an iPhoneOS SDK first, then build from this directory:

```sh
cd iosTweak
make package
```

For rootless jailbreaks:

```sh
cd iosTweak
make package THEOS_PACKAGE_SCHEME=rootless
```

The generated `.deb` will be placed in `iosTweak/packages/`.

## GitHub Actions

The repository includes `.github/workflows/ios-tweak.yml`, which builds both rootful and rootless `.deb` packages on `macos-latest`.

Run it manually from GitHub:

1. Open **Actions**.
2. Select **Build iOS Tweak**.
3. Click **Run workflow**.
4. Download `OlcboxKeepAlive-rootful` or `OlcboxKeepAlive-rootless` from workflow artifacts.

If Actions fails with `working directory .../iosTweak: No such file or directory`, the `iosTweak` directory was not pushed to GitHub. Add it to Git and push again:

```sh
git add iosTweak .github/workflows/ios-tweak.yml
git commit -m "Add iOS keepalive tweak build"
git push
```