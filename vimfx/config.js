// Set options.
let options = {
    "hints.chars": "jdkslaghrueiwonc mv",
    "mode.normal.scroll_page_down": "",
    "mode.caret.exit": "<escape>    <c-[>",
    "mode.hints.exit": "<escape>    <c-[>",
    "mode.find.exit": "<escape>    <enter>    <c-[>",
    "mode.marks.exit": "<escape>     <c-[>",
    };
Object.entries(options).forEach(([option, value]) => vimfx.set(option, value));

let {commands} = vimfx.modes.normal;

vimfx.addCommand({
        name: "search_tabs",
        description: "Search tabs",
        category: "tabs",
        order: commands.focus_location_bar.order + 1,
    },
    (args) => {
        let {vim} = args;
        let {gURLBar} = vim.window;
        gURLBar.value = "";
        commands.focus_location_bar.run(args);
        gURLBar.value = "* ";
        gURLBar.onInput(new vim.window.KeyboardEvent("input"));
    });
vimfx.set("custom.mode.normal.search_tabs", "b");

