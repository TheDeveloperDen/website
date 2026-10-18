type ElmPagesInit = {
  load: (elmLoaded: Promise<unknown>) => Promise<void>;
  flags: unknown;
};

const config: ElmPagesInit = {
  load: async function (elmLoaded) {
    const app: any = await elmLoaded;

    app.ports.setTheme.subscribe((theme: string) => {
      document.documentElement.dataset.theme = theme;
      try {
        localStorage.setItem("den-theme", theme);
      } catch (e) {}
    });
  },
  flags: function () {
    return "You can decode this in Shared.elm using Json.Decode.string!";
  },
};

export default config;
