-- Minimal Octo.nvim configuration for GitHub integration
-- Provides essential GitHub functionality with minimal overhead

return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Octo",
  event = { { event = "BufReadCmd", pattern = "octo://*" } },
  opts = {
    -- Minimal configuration for essential features
    enable_builtin = true,
    use_local_fs = false,
    
    -- GitHub CLI integration
    gh_cmd = "gh",
    gh_env = {},
    
    -- UI Configuration
    default_remote = { "upstream", "origin" },
    reaction_viewer_hint_icon = " ",
    user_icon = " ",
    timeline_marker = " ",
    timeline_indent = "2",
    right_bubble_delimiter = "",
    left_bubble_delimiter = "",
    snippet_context_lines = 4,
    
    -- File panel configuration
    file_panel = {
      size = 10,
      use_icons = true,
    },
    
    -- Mappings (minimal set for essential operations)
    mappings = {
      issue = {
        close_issue = { lhs = "<localleader>ic", desc = "close issue" },
        reopen_issue = { lhs = "<localleader>io", desc = "reopen issue" },
        list_issues = { lhs = "<localleader>il", desc = "list open issues on same repo" },
        reload = { lhs = "<C-r>", desc = "reload issue" },
        open_in_browser = { lhs = "<C-b>", desc = "open issue in browser" },
        copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
        add_assignee = { lhs = "<localleader>aa", desc = "add assignee" },
        remove_assignee = { lhs = "<localleader>ad", desc = "remove assignee" },
        add_label = { lhs = "<localleader>la", desc = "add label" },
        remove_label = { lhs = "<localleader>ld", desc = "remove label" },
        add_comment = { lhs = "<localleader>ca", desc = "add comment" },
        delete_comment = { lhs = "<localleader>cd", desc = "delete comment" },
        react_hooray = { lhs = "<localleader>rp", desc = "add/remove 🎉 reaction" },
        react_heart = { lhs = "<localleader>rh", desc = "add/remove ❤️ reaction" },
        react_eyes = { lhs = "<localleader>re", desc = "add/remove 👀 reaction" },
        react_thumbs_up = { lhs = "<localleader>r+", desc = "add/remove 👍 reaction" },
        react_thumbs_down = { lhs = "<localleader>r-", desc = "add/remove 👎 reaction" },
        react_rocket = { lhs = "<localleader>rr", desc = "add/remove 🚀 reaction" },
        react_laugh = { lhs = "<localleader>rl", desc = "add/remove 😄 reaction" },
        react_confused = { lhs = "<localleader>rc", desc = "add/remove 😕 reaction" },
      },
      pull_request = {
        checkout_pr = { lhs = "<localleader>po", desc = "checkout PR" },
        merge_pr = { lhs = "<localleader>pm", desc = "merge PR" },
        list_commits = { lhs = "<localleader>pc", desc = "list PR commits" },
        list_changed_files = { lhs = "<localleader>pf", desc = "list PR changed files" },
        show_pr_diff = { lhs = "<localleader>pd", desc = "show PR diff" },
        add_reviewer = { lhs = "<localleader>va", desc = "add reviewer" },
        remove_reviewer = { lhs = "<localleader>vd", desc = "remove reviewer" },
        review_start = { lhs = "<localleader>vs", desc = "start a review for the current PR" },
        review_resume = { lhs = "<localleader>vr", desc = "resume a pending review" },
      },
      review_thread = {
        goto_issue = { lhs = "<localleader>gi", desc = "navigate to a local repo issue" },
        add_comment = { lhs = "<localleader>ca", desc = "add comment" },
        delete_comment = { lhs = "<localleader>cd", desc = "delete comment" },
      },
      submit_win = {
        approve_review = { lhs = "<C-a>", desc = "approve review" },
        comment_review = { lhs = "<C-m>", desc = "comment review" },
        request_changes = { lhs = "<C-r>", desc = "request changes review" },
        close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
      },
      review_diff = {
        submit_review = { lhs = "<localleader>vs", desc = "submit review" },
        discard_review = { lhs = "<localleader>vd", desc = "discard review" },
        add_review_comment = { lhs = "<localleader>ca", desc = "add a new review comment" },
        add_review_suggestion = { lhs = "<localleader>sa", desc = "add a new review suggestion" },
        next_thread = { lhs = "]t", desc = "move to next thread" },
        prev_thread = { lhs = "[t", desc = "move to previous thread" },
        select_next_entry = { lhs = "]q", desc = "move to next changed file" },
        select_prev_entry = { lhs = "[q", desc = "move to previous changed file" },
        select_first_entry = { lhs = "[Q", desc = "move to first changed file" },
        select_last_entry = { lhs = "]Q", desc = "move to last changed file" },
        close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
        toggle_viewed = { lhs = "<localleader>tv", desc = "toggle viewer viewed state" },
        goto_file = { lhs = "gf", desc = "go to file" },
      },
      file_panel = {
        submit_review = { lhs = "<localleader>vs", desc = "submit review" },
        discard_review = { lhs = "<localleader>vd", desc = "discard review" },
        select_next_entry = { lhs = "j", desc = "move to next changed file" },
        select_prev_entry = { lhs = "k", desc = "move to previous changed file" },
        select_first_entry = { lhs = "gg", desc = "move to first changed file" },
        select_last_entry = { lhs = "G", desc = "move to last changed file" },
        close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
        toggle_viewed = { lhs = "<localleader>tv", desc = "toggle viewer viewed state" },
      },
    },
    
    -- Picker configuration
    picker = "telescope",
    picker_config = {
      use_emojis = false,
      mappings = {
        open_in_browser = { lhs = "<C-b>", desc = "open issue in browser" },
        copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
        checkout_pr = { lhs = "<C-o>", desc = "checkout pull request" },
        merge_pr = { lhs = "<C-r>", desc = "merge pull request" },
      },
    },
    
    -- Colors
    colors = {
      white = "#ffffff",
      grey = "#727272",
      black = "#000000",
      red = "#ff0000",
      dark_red = "#cc0000",
      green = "#00ff00",
      dark_green = "#00cc00",
      yellow = "#ffff00",
      dark_yellow = "#cccc00",
      blue = "#0000ff",
      dark_blue = "#0000cc",
      purple = "#ff00ff",
    },
  },
  config = function(_, opts)
    require("octo").setup(opts)
    
    -- Create user command for common operations
    vim.api.nvim_create_user_command("OctoReview", function()
      vim.cmd("Octo pr list")
    end, { desc = "List pull requests" })
  end,
}