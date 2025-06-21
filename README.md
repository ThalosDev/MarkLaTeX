# MarkLaTeX

## Prerequisites

- **Node.js** (v18 or higher)
- **npm** (Node Package Manager)
- **Pandoc** (for document conversion)
- **TeX Live** (for LaTeX compilation)
- **bash** (for running shell scripts)

## Installing Dependencies

1. **Install Node.js and npm**  
    [Download and install Node.js](https://nodejs.org/) (includes npm).

2. **Install Pandoc**  
    ```sh
    sudo apt-get install pandoc
    ```
    Or see [Pandoc installation guide](https://pandoc.org/installing.html).

3. **Install TeX Live**  
    ```sh
    sudo apt-get install texlive-full
    ```
    Or see [TeX Live installation guide](https://www.tug.org/texlive/).

4. **Install Node.js dependencies**  
    In the project directory, run:
    ```sh
    npm install
    ```

## Usage

To build the documentation, run:

```sh
./build_docs.sh
```

This script will:

- Install npm dependencies if needed.
- Convert Markdown files to PDF using Pandoc and LaTeX.
- Output the generated documentation in the `docs/` directory.

**Note:** Ensure all prerequisites are installed before running the script.