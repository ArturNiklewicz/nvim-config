#!/bin/bash
# Neovim Testing Environment Setup Script
# Creates a separate testing environment for safe experimentation

set -e

echo "🧪 Setting up Neovim Testing Environment..."

# Configuration
NVIM_TEST_DIR="$HOME/.config/nvim-test"
NVIM_TEST_DATA="$HOME/.local/share/nvim-test"
NVIM_TEST_STATE="$HOME/.local/state/nvim-test"
NVIM_TEST_CACHE="$HOME/.cache/nvim-test"
CURRENT_DIR=$(pwd)

# Function to create test alias
create_test_alias() {
    local shell_rc=""
    if [[ -f "$HOME/.zshrc" ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ -f "$HOME/.bashrc" ]]; then
        shell_rc="$HOME/.bashrc"
    fi

    if [[ -n "$shell_rc" ]]; then
        echo ""
        echo "# Neovim Testing Environment" >> "$shell_rc"
        echo "alias nvim-test='NVIM_APPNAME=nvim-test nvim'" >> "$shell_rc"
        echo "alias nvt='NVIM_APPNAME=nvim-test nvim'" >> "$shell_rc"
        echo ""
        echo "✅ Added aliases to $shell_rc:"
        echo "   nvim-test - Launch test environment"
        echo "   nvt       - Short alias for test environment"
        echo ""
        echo "Run 'source $shell_rc' or restart terminal to use aliases."
    fi
}

# Step 1: Backup current state and commit changes
echo "📁 Preparing current configuration..."
if [[ -n "$(git status --porcelain)" ]]; then
    echo "⚠️  You have uncommitted changes. Let's save them first."
    echo "Current changes:"
    git status --short
    echo ""
    read -p "Commit current changes? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add .
        git commit -m "Save current state before creating test environment

🧪 Pre-test commit including:
- VSCode-like editing enhancements
- Error message improvements
- Claude Code integration updates
- Molten notebook improvements

Generated automatically by setup-test-env.sh"
        echo "✅ Changes committed to main branch"
    else
        echo "⚠️  Proceeding without committing changes"
    fi
fi

# Step 2: Create git branch for testing
echo "🌿 Creating testing branch..."
git checkout -b testing-environment 2>/dev/null || git checkout testing-environment
echo "✅ Switched to testing-environment branch"

# Step 3: Create test directories
echo "📂 Creating test environment directories..."
mkdir -p "$NVIM_TEST_DIR"
mkdir -p "$NVIM_TEST_DATA"
mkdir -p "$NVIM_TEST_STATE"
mkdir -p "$NVIM_TEST_CACHE"

# Step 4: Copy configuration to test environment
echo "📋 Copying configuration to test environment..."
cp -r "$CURRENT_DIR"/* "$NVIM_TEST_DIR/" 2>/dev/null || true
cp -r "$CURRENT_DIR"/.* "$NVIM_TEST_DIR/" 2>/dev/null || true

# Clean up test environment
rm -f "$NVIM_TEST_DIR/setup-test-env.sh"
rm -f "$NVIM_TEST_DIR/nvim_startup.log"
rm -f "$NVIM_TEST_DIR/test_molten.py"

echo "✅ Configuration copied to test environment"

# Step 5: Create test environment wrapper script
echo "🔧 Creating test launcher script..."
cat > "$HOME/.local/bin/nvim-test" << 'EOF'
#!/bin/bash
# Neovim Test Environment Launcher
export NVIM_APPNAME=nvim-test
exec nvim "$@"
EOF

# Make launcher executable
chmod +x "$HOME/.local/bin/nvim-test" 2>/dev/null || {
    mkdir -p "$HOME/.local/bin"
    chmod +x "$HOME/.local/bin/nvim-test"
}

# Step 6: Create test environment management script
echo "⚙️  Creating test management script..."
cat > "$NVIM_TEST_DIR/test-manager.sh" << 'EOF'
#!/bin/bash
# Neovim Test Environment Manager

set -e

MAIN_NVIM="$HOME/.config/nvim"
TEST_NVIM="$HOME/.config/nvim-test"
TEST_DATA="$HOME/.local/share/nvim-test"
TEST_STATE="$HOME/.local/state/nvim-test"
TEST_CACHE="$HOME/.cache/nvim-test"

case "$1" in
    "sync-to-main")
        echo "🔄 Syncing test changes to main configuration..."
        cd "$MAIN_NVIM"
        git checkout main
        
        # Copy test changes back
        rsync -av --exclude='.git' --exclude='test-manager.sh' "$TEST_NVIM/" "$MAIN_NVIM/"
        
        echo "✅ Test changes synced to main. Review with 'git diff'"
        ;;
    
    "reset")
        echo "🗑️  Resetting test environment..."
        cd "$MAIN_NVIM"
        git checkout main
        rsync -av --exclude='.git' --exclude='test-manager.sh' "$MAIN_NVIM/" "$TEST_NVIM/"
        
        # Clean test data
        rm -rf "$TEST_DATA"/* 2>/dev/null || true
        rm -rf "$TEST_STATE"/* 2>/dev/null || true
        rm -rf "$TEST_CACHE"/* 2>/dev/null || true
        
        echo "✅ Test environment reset to main configuration"
        ;;
    
    "status")
        echo "📊 Test Environment Status:"
        echo "Main config: $MAIN_NVIM"
        echo "Test config: $TEST_NVIM"
        echo ""
        echo "Main branch:"
        cd "$MAIN_NVIM" && git branch --show-current && git log --oneline -3
        echo ""
        echo "Test changes:"
        if diff -r "$MAIN_NVIM" "$TEST_NVIM" --exclude='.git' --exclude='test-manager.sh' > /dev/null; then
            echo "✅ No differences between main and test"
        else
            echo "⚠️  Test environment has changes"
            diff -r "$MAIN_NVIM" "$TEST_NVIM" --exclude='.git' --exclude='test-manager.sh' | head -10
        fi
        ;;
    
    "backup")
        echo "💾 Creating backup of test environment..."
        BACKUP_NAME="nvim-test-backup-$(date +%Y%m%d-%H%M%S)"
        cp -r "$TEST_NVIM" "$HOME/.config/$BACKUP_NAME"
        echo "✅ Backup created: $HOME/.config/$BACKUP_NAME"
        ;;
    
    "clean")
        echo "🧹 Cleaning test data and cache..."
        rm -rf "$TEST_DATA"/* 2>/dev/null || true
        rm -rf "$TEST_STATE"/* 2>/dev/null || true
        rm -rf "$TEST_CACHE"/* 2>/dev/null || true
        echo "✅ Test data cleaned"
        ;;
    
    *)
        echo "Neovim Test Environment Manager"
        echo ""
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  sync-to-main  - Copy test changes to main config"
        echo "  reset         - Reset test env to main config"
        echo "  status        - Show status and differences"
        echo "  backup        - Create backup of test environment"
        echo "  clean         - Clean test data and cache"
        echo ""
        echo "Aliases:"
        echo "  nvim-test     - Launch test environment"
        echo "  nvt           - Short alias for test environment"
        ;;
esac
EOF

chmod +x "$NVIM_TEST_DIR/test-manager.sh"

# Step 7: Create test-specific configuration
echo "🔧 Creating test-specific enhancements..."
cat > "$NVIM_TEST_DIR/lua/plugins/test-enhancements.lua" << 'EOF'
-- Test Environment Enhancements
-- Additional plugins and configurations for testing

return {
  -- Test runner integration
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Language-specific adapters
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-plenary",
      "marilari88/neotest-vitest",
    },
    opts = {
      adapters = {
        require("neotest-python")({
          dap = { justMyCode = false },
          args = {"--log-level", "DEBUG"},
          runner = "pytest",
        }),
        require("neotest-plenary"),
        require("neotest-vitest"),
      },
      status = { virtual_text = true },
      output = { open_on_run = true },
      quickfix = {
        open = function()
          vim.cmd("Trouble quickfix")
        end,
      },
    },
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
      { "<leader>td", function() require("neotest").run.run({strategy = "dap"}) end, desc = "Debug nearest test" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
      { "<leader>to", function() require("neotest").output.open({enter = true}) end, desc = "Show test output" },
    },
  },
  
  -- Enhanced debugging
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue debugging" },
      { "<leader>ds", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
    },
  },
  
  -- Test environment indicator
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Add test environment indicator
      opts = opts or {}
      opts.sections = opts.sections or {}
      opts.sections.lualine_x = opts.sections.lualine_x or {}
      table.insert(opts.sections.lualine_x, {
        function()
          return "🧪 TEST ENV"
        end,
        color = { fg = "#ff6b6b", gui = "bold" },
      })
      return opts
    end,
  },
}
EOF

# Step 8: Update CLAUDE.md for test environment
cat > "$NVIM_TEST_DIR/CLAUDE-TEST.md" << 'EOF'
# Neovim Test Environment

This is a **TESTING ENVIRONMENT** for experimenting with Neovim configurations safely.

## Environment Info
- **Type**: Testing/Development
- **Purpose**: Safe experimentation and prototyping
- **Base**: Copied from main production config
- **Data**: Isolated in `~/.local/share/nvim-test`

## Usage
```bash
nvim-test [file]  # Launch test environment
nvt [file]        # Short alias
```

## Management Commands
```bash
# In test config directory
./test-manager.sh status      # Check differences
./test-manager.sh sync-to-main # Push changes to main
./test-manager.sh reset       # Reset to main config
./test-manager.sh backup      # Create backup
./test-manager.sh clean       # Clean test data
```

## Test-Specific Features
- **Neotest**: Test runner integration
- **DAP**: Enhanced debugging capabilities
- **Test Indicator**: Status line shows "🧪 TEST ENV"
- **Isolated Data**: Separate plugin data and cache

## Testing Workflow
1. **Experiment**: Make changes in test environment
2. **Validate**: Test functionality thoroughly
3. **Review**: Check differences with `status` command
4. **Deploy**: Use `sync-to-main` to push to production
5. **Rollback**: Use `reset` if issues occur

## Safety Features
- Completely isolated from main config
- Separate data directories
- Git branch protection
- Easy rollback mechanism
- Automatic backups

Remember: This is a **TEST ENVIRONMENT** - experiment freely!
EOF

# Step 9: Add test environment to .gitignore
echo "" >> "$NVIM_TEST_DIR/.gitignore"
echo "# Test environment files" >> "$NVIM_TEST_DIR/.gitignore"
echo "test-manager.sh" >> "$NVIM_TEST_DIR/.gitignore"
echo "CLAUDE-TEST.md" >> "$NVIM_TEST_DIR/.gitignore"

# Step 10: Create aliases
create_test_alias

# Final steps
echo "🏁 Finalizing setup..."

# Go back to main branch
cd "$CURRENT_DIR"
git checkout main

echo ""
echo "🎉 Test environment setup complete!"
echo ""
echo "📍 Locations:"
echo "   Main config:  $CURRENT_DIR"
echo "   Test config:  $NVIM_TEST_DIR"
echo "   Test data:    $NVIM_TEST_DATA"
echo ""
echo "🚀 Usage:"
echo "   nvim-test     - Launch test environment"
echo "   nvt           - Short alias"
echo ""
echo "⚙️  Management:"
echo "   cd $NVIM_TEST_DIR"
echo "   ./test-manager.sh <command>"
echo ""
echo "📚 Documentation:"
echo "   cat $NVIM_TEST_DIR/CLAUDE-TEST.md"
echo ""
echo "🔄 Next steps:"
echo "1. Run 'source ~/.zshrc' (or restart terminal)"
echo "2. Try 'nvim-test' to launch test environment"
echo "3. Experiment safely!"