# iMessage One-time-password (otp) Finder

If you use Safari on macOS, you've likely noticed that Safari will auto-fill OTP codes you receive via iMessage. If you use a different browser, you need to go find the code yourself and copy+paste it.

OtpFinder is a small app that watches the iMessage SQLite database for changes and checks for incoming OTP codes. If it finds one, it copies it to your clipboard.


## macOS Permissions

### Full Disk Access
To watch the iMessage DB for changes, full disk access is required. You'll need to enable this manually in Security settings. You can check if permissions have been granted successfully through the status bar menu for the app:

If working:

<img width="157" alt="image" src="https://user-images.githubusercontent.com/25035271/179367742-4789f164-bf39-4a3a-80af-77771479bed8.png">


If not working:

<img width="187" alt="image" src="https://user-images.githubusercontent.com/25035271/179367867-b363acc2-2c1d-4732-bd6a-26cbdebfc1a4.png">
