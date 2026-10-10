# Smart Organizer Pro 🗂️

**A simple Windows file organizer with automatic sorting, folder selection, activity logging, and undo support.**

Smart Organizer Pro is a Windows utility built with PowerShell and Batch that helps you organize files into categorized folders. Choose a directory, sort files by their extensions, and keep track of file movements through an activity log.

Whether you're cleaning up your Downloads folder, Desktop, external drive, or another data directory, Smart Organizer Pro aims to make file organization easier.

## ✨ Features

- **📁 Custom Folder Selection** — Choose the directory you want to organize.
- **⚡ Automatic File Sorting** — Sort files into folders based on their extensions.
- **🗃️ Multiple Categories** — Organize videos, photos, documents, music, archives, applications, code files, fonts, and more.
- **↩️ Undo Support** — Restore files from the most recent organization operation when their original locations are available.
- **📋 Activity Logging** — Keep a record of file movements.
- **🛡️ Duplicate Protection** — Avoid overwriting existing files during supported move operations.
- **⏳ Temporary File Exclusions** — Skip common incomplete download formats.
- **🖥️ Simple Interface** — Launch the utility through a Windows batch file and follow the menu.
- **💻 No Installation Wizard** — Run the scripts directly on a compatible Windows system.

> Note: Features depend on the version of the scripts included in the repository. Review and test the implementation before relying on undo, logging, or file-protection behavior.

## 📂 File Categories

The organizer can sort supported file types into categories such as:

| Category | Example extensions |
|---|---|
| Videos | `.mp4`, `.mkv`, `.avi`, `.mov`, `.webm` |
| Photos | `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`, `.heic` |
| Documents | `.pdf`, `.docx`, `.doc`, `.rtf`, `.epub` |
| Text Files | `.txt`, `.md`, `.log`, `.json`, `.xml` |
| Spreadsheets | `.xls`, `.xlsx`, `.csv`, `.ods` |
| Presentations | `.ppt`, `.pptx`, `.odp` |
| Music | `.mp3`, `.wav`, `.flac`, `.aac`, `.ogg` |
| Archives | `.zip`, `.rar`, `.7z`, `.tar`, `.gz` |
| Applications | `.exe`, `.msi`, `.msix`, `.apk` |
| Code | `.js`, `.ts`, `.py`, `.java`, `.html`, `.css` |
| Design | `.blend`, `.fbx`, `.obj`, `.stl`, `.dwg` |
| Fonts | `.ttf`, `.otf`, `.woff`, `.woff2` |
| Other Downloads | Other explicitly supported extensions |
| Others | Remaining files that the organizer processes |

The supported extensions depend on the current script configuration.

## 🖥️ Requirements

- Windows 10 or Windows 11
- Windows PowerShell
- Permission to read and move files in the selected directory

The utility uses a `.bat` launcher and a `.ps1` PowerShell script.

## 🚀 Getting Started

### 1. Download the project

Clone the repository:

```bash
git clone https://github.com/razzm7/SmartOrganizerPro.git
```

Alternatively, download the repository as a ZIP file from GitHub and extract it.

### 2. Open the project folder

Make sure the launcher and PowerShell script are in the same directory.

Expected structure:

```text
SmartOrganizerPro/
├── SmartOrganizerPro.bat
├── SmartOrganizerPro.ps1
├── README.md
└── .gitignore
```

The log file may be created when the application runs.

### 3. Launch the application

Double-click:

```text
SmartOrganizerPro.bat
```

If Windows displays a security warning, verify that the scripts came from your trusted repository before proceeding.

### 4. Choose an operation

Follow the options displayed by the application. In versions that provide the menu, the operations include:

1. **Organize a folder** — select a directory and sort its files.
2. **Undo last organization** — attempt to restore files from the most recent operation.
3. **View activity log** — review recorded file movements.
4. **Exit** — close the application.

Menu options may differ between releases.

## 📖 How It Works

Smart Organizer Pro uses file extensions to determine the destination category for each file.

For example:

```text
Downloads/
├── holiday.mp4
├── photo.jpg
├── report.pdf
└── archive.zip
```

After organizing, the directory may look like:

```text
Downloads/
├── Videos/
│   └── holiday.mp4
├── Photos/
│   └── photo.jpg
├── Documents/
│   └── report.pdf
└── Archives/
    └── archive.zip
```

Files are moved rather than duplicated. Depending on the configured rules, unsupported or unrecognized files may be placed in an `Others` folder.

## ↩️ Undo and Activity Logs

If supported by the version you are using, the undo feature uses recorded file paths to attempt to return files to their original locations.

**Important considerations:**

- Keep the activity log in its expected location.
- Do not manually edit the log unless you understand its format.
- Undo may skip a file if its original location already contains a file with the same name.
- Do not assume every move can be reversed after files or logs have been manually changed.
- Back up important files before organizing them.

## 🛡️ Safety Recommendations

Smart Organizer Pro moves files and can change the structure of your directories.

- Test the application on a temporary directory containing copies of files first.
- Back up important data before using it.
- Avoid organizing Windows system directories or folders containing installed applications.
- Review the PowerShell and Batch scripts before running them.
- Do not run the organizer as administrator unless genuinely necessary.
- Never assume a file is safe just because it has a familiar extension.

The organizer is a file-management utility, not an antivirus or malware scanner.

## 🔧 Troubleshooting

### The folder-selection dialog does not appear

- Check whether the dialog is hidden behind the terminal using `Alt + Tab`.
- Verify that both the `.bat` and `.ps1` files are present.
- Review any PowerShell error messages.
- Check that the launcher uses the correct PowerShell options for Windows Forms dialogs, including STA mode when required.

### The application does not organize files

- Confirm that the selected directory is correct.
- Check that the directory contains files with supported extensions.
- Verify that you have permission to move the files.
- Review the terminal output and activity log for errors.

### Undo does not restore every file

- Check whether the original paths are occupied.
- Confirm that the relevant activity log is still available.
- Avoid manually moving organized files before using undo.

## 🛠️ Built With

- **PowerShell** — file-management operations and Windows integration
- **Windows Batch** — application launcher
- **Windows Forms** — folder-selection dialog, where supported by the implementation

## 🗺️ Roadmap

Potential future improvements include:

- [ ] Recursive organization of subdirectories
- [ ] Customizable file categories and extensions
- [ ] Preview mode before moving files
- [ ] Configurable destination folders
- [ ] More detailed activity logs
- [ ] Multiple-operation undo history
- [ ] Improved error handling and recovery
- [ ] Optional startup automation
- [ ] Unit and integration tests

## 🤝 Contributing

Contributions, bug reports, and feature suggestions are welcome.

1. Fork the repository.
2. Create a feature branch.
3. Make and test your changes.
4. Submit a pull request describing the changes.

For bugs, include your Windows version, the operation you attempted, and any relevant error messages. Avoid sharing private file paths or personal data.

## 📄 License

No license has been specified yet.

Before publishing, add a `LICENSE` file with the terms under which others may use, modify, and redistribute this project. Without an applicable license, others generally do not receive permission to reuse the code beyond rights granted by law.

## 👨‍💻 Author

**YOUR NAME**

GitHub: [@razzm7](https://github.com/razzm7)

---

If you find this project useful, consider giving the repository a ⭐ on GitHub!