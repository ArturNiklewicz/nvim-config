# AstroNvim Template

**NOTE:** This is for AstroNvim v5+

A template for getting started with [AstroNvim](https://github.com/AstroNvim/AstroNvim)

## 🛠️ Installation

#### Make a backup of your current nvim and shared folder

```shell
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

#### Create a new user repository from this template

Press the "Use this template" button above to create a new repository to store your user configuration.

You can also just clone this repository directly if you do not want to track your user configuration in GitHub.

#### Clone the repository

```shell
git clone https://github.com/<your_user>/<your_repository> ~/.config/nvim
```

#### Start Neovim

```shell
nvim
```

## 🧪 Testing

This configuration includes a minimal testing infrastructure using plenary.nvim (which is already included as a dependency).

### Writing Tests

Tests should be placed in the `tests/unit/` directory and follow the naming convention `*_spec.lua`. Here's a simple example:

```lua
describe("My feature", function()
  it("should do something", function()
    assert.equals(2 + 2, 4)
  end)
end)
```

See `tests/unit/example_spec.lua` for more examples of testing patterns.

### Running Tests

There are several ways to run tests:

#### 1. Using Keybindings (inside Neovim)

- `<Leader>tt` - Run tests in current file (if it's a `*_spec.lua` file)
- `<Leader>ta` - Run all tests in the `tests/unit/` directory
- `<Leader>tn` - Run the nearest test to your cursor

#### 2. Using the Test Runner Script

```bash
# Run all tests
./run-tests.sh

# Run only unit tests
./run-tests.sh unit

# Run a specific test file
./run-tests.sh file tests/unit/example_spec.lua
```

#### 3. Using Neovim Commands Directly

```bash
# Run all tests
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/unit/" -c "q"

# Run a specific test file
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile tests/unit/example_spec.lua" -c "q"
```

### Test Structure

```
tests/
├── unit/              # Unit tests for individual components
│   └── example_spec.lua
├── fixtures/          # Test data and fixtures
└── minimal_init.lua   # Minimal init for clean test environment
```

### Best Practices

1. **Isolation**: Tests run with a minimal init file to ensure a clean environment
2. **Naming**: Use descriptive test names that explain what is being tested
3. **Organization**: Group related tests using `describe` blocks
4. **Setup/Teardown**: Use `before_each` and `after_each` for test setup and cleanup

### Rollback Capability

The testing infrastructure is designed to be minimal and non-intrusive:
- No new plugins are installed (uses existing plenary.nvim dependency)
- Test commands are added to existing keybindings without overriding anything
- All test files are isolated in the `tests/` directory
- To remove testing, simply delete the `tests/` directory and remove the test keybindings from `lua/plugins/astrocore.lua`

## 🐙 GitHub Integration (Octo.nvim)

This configuration includes minimal GitHub integration using Octo.nvim and GitHub CLI.

### Prerequisites

- GitHub CLI (`gh`) installed and authenticated:
  ```bash
  brew install gh  # macOS
  gh auth login    # Authenticate with GitHub
  ```

### GitHub Keybindings

All GitHub commands are under the `<Leader>g` prefix:

#### Issue Management
- `<Leader>gi` - List GitHub issues
- `<Leader>gI` - Create new GitHub issue
- `<Leader>gb` - Create issue from current line

#### Pull Request Management
- `<Leader>gp` - List pull requests
- `<Leader>gP` - Create new pull request
- `<Leader>gf` - Show PR diff
- `<Leader>go` - Checkout PR locally
- `<Leader>gv` - View PR in browser
- `<Leader>gc` - Show PR checks/CI status
- `<Leader>gm` - Merge current PR (interactive)

#### Code Review
- `<Leader>gR` - Start code review
- `<Leader>gC` - Add comment
- `<Leader>ga` - Add assignee
- `<Leader>gl` - Add label

#### Navigation & Search
- `<Leader>gr` - List repositories
- `<Leader>gs` - Search GitHub
- `<Leader>g/` - Quick search GitHub repos

### Usage Examples

1. **View and manage PRs**:
   - Press `<Leader>gp` to list all PRs
   - Navigate to a PR and press `<Enter>` to open it
   - Use `<Leader>go` to checkout the PR locally

2. **Create an issue from code**:
   - Place cursor on a line with a TODO or bug
   - Press `<Leader>gb` to create an issue with that line as title

3. **Quick PR workflow**:
   - `<Leader>gv` to view PR in browser
   - `<Leader>gc` to check CI status
   - `<Leader>gm` to merge when ready

4. **Code review workflow**:
   - Open a PR with `<Leader>gp` and select one
   - Press `<Leader>gR` to start a review
   - Navigate code and use `<Leader>gC` to add comments
   - Submit review when complete

### Additional Octo Commands

- `:Octo <tab>` - See all available Octo commands
- `:OctoReview` - Quick access to PR list
- `:Octo pr create` - Create PR with template
- `:Octo issue create` - Create issue with template

### Configuration

The Octo plugin is configured in `lua/plugins/octo.lua` with:
- Minimal setup for essential features
- Telescope integration for fuzzy finding
- GitHub CLI integration for additional functionality
- Local keybindings within Octo buffers (see `:h octo-mappings`)
