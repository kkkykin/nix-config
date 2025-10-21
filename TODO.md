# Architecture Improvements

1. [x] Consolidate baseline modules into a profile (e.g., `modules/profiles/server.nix`) and apply them from `flake.nix` so each host file only contains host-specific imports.
2. [ ] Extract SOPS-managed secrets into reusable feature modules (e.g., `modules/secrets/postgresql.nix`, `modules/secrets/freshrss.nix`) to centralize secret ownership and reuse across hosts.
3. [ ] Publish shared Home Manager modules via `outputs.homeManagerModules` for reuse across multiple users or external flakes.
4. [ ] Standardize how `pkgs.unstable` packages are consumed by wrapping common selections or helpers, reducing ad-hoc references in host modules.
5. [ ] Add `checks` outputs (NixOS, Home Manager builds) to the flake so `nix flake check` covers configuration and user profile evaluations automatically.
