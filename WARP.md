# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## High-level code architecture

This is a single-file Python application that uses the `tkinter` library for its graphical user interface (GUI). The application is designed to download multiple files from a list of URLs provided by the user.

The core logic is in the `FileDownloader` class in `file_downloader.py`:

-   **`__init__` and `create_widgets`**: These methods set up the main application window and all the GUI elements, such as text boxes for URLs, a field for the save path, a progress bar, and the download button.
-   **`browse_path`**: This method opens a dialog to allow the user to select a directory where the downloaded files will be saved.
-   **`download_file`**: This method handles the download of a single file. It uses the `requests` library to fetch the file, and it intelligently determines the filename from the URL or the `Content-Disposition` header. It also handles potential filename conflicts by appending a counter to the filename if a file with the same name already exists.
-   **`start_download`**: This method is triggered when the "Start Download" button is clicked. It retrieves the list of URLs from the text box and the save path. It then starts a new thread to download the files, so the GUI remains responsive during the download process.
-   **`run`**: This method starts the `tkinter` event loop, which displays the GUI and waits for user interaction.

The application is packaged into a single executable file using `pyinstaller`, as defined in the `file_downloader.spec` file.

## Common commands

### Setting up the development environment

To set up the development environment, you'll need to install the Python dependencies listed in `requirement.txt`. It is recommended to use a virtual environment.

```bash
# Create a virtual environment (optional but recommended)
python -m venv venv
venv\Scripts\activate

# Install the dependencies
pip install -r requirement.txt
```

### Running the application

To run the application from the source code, execute the following command:

```bash
python file_downloader.py
```

### Building the executable

To build the executable file, you will need to have `pyinstaller` installed (it's listed in `requirement.txt`). Then, run the following command:

```bash
pyinstaller file_downloader.spec
```

This will create a `dist` directory containing the `file_downloader.exe` executable.

## Development guidelines

The `.cursorrules` file provides the following guidelines for development:

-   **Performance First**: Write efficient and resource-friendly code.
-   **User Experience**: Design for non-technical, Chinese-speaking users. The GUI should be intuitive and simple.
-   **Development Standards**: Use the latest Python features and best practices, following PEP 8. Emphasize code readability and maintainability.
-   **Requirement Understanding**: Understand user needs and provide intuitive solutions.

