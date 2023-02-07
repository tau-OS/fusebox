project "fusebox" {
    rpm {
        spec = "fusebox.spec"
    }

    flatpak {
        manifest = "com.fyralabs.Fusebox.json"
    }
}