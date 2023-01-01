project "fusebox" {
    rpm {
        spec = "fusebox.spec"
    }

    flatpak {
        manifest = "co.tauos.Fusebox.json"
    }
}