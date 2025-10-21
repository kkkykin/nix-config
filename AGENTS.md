# Repository Guidelines

## Project Structure & Module Organization
The flake in `flake.nix` defines hosts through `nixosConfigurations` and passes shared inputs (stable, unstable, sops, home-manager). Host-specific options live in `hosts/<hostname>`; use `default.nix` for system logic and subdirectories (for example, `caddy/`) for service fragments. User profiles are split into `users/<name>/nixos.nix` for system accounts and `users/<name>/home.nix` for Home Manager; shared Home Manager modules sit in `home/`, while reusable NixOS modules belong in `modules/`. Secrets stay encrypted in `secrets/` with corresponding keys in `keys/`; do not commit plain-text credentials.

## Build, Test, and Development Commands
- `sudo nixos-rebuild switch --flake .#asus` (or `.#legion-wsl`) applies host configuration on the target machine.
- `nixos-rebuild test --flake .#asus` runs activation in a safe dry-run and catches evaluation errors.
- `home-manager switch --flake .#kkky@asus` updates user profiles; the host suffix keeps cross-host profiles consistent.
- `nix develop` loads the `sops-nix` shell, importing required PGP keys before touching encrypted secrets.

## Coding Style & Naming Conventions
Indent Nix expressions with two spaces and align attribute values; keep attribute names lower-case with hyphenated words (`programs.git`, `services.caddy`). Group host logic into small modules and expose options via `modules/<feature>.nix` rather than growing monolithic files. Run `nix fmt` (or `nixpkgs-fmt`) before committing to keep attribute ordering and string quoting consistent.

## Testing Guidelines
Run `nix flake check` before every PR to ensure flake inputs and system evaluations stay reproducible. For host-specific changes, build the closure locally with `nix build .#nixosConfigurations.asus.config.system.build.toplevel` to surface missing dependencies. When editing Home Manager modules, lint by running `home-manager build --flake .#nixos@legion-wsl` to verify user evaluation succeeds.

## Commit & Pull Request Guidelines
Follow the existing Conventional Commit style: `type(scope): summary`, e.g., `feat(home): add neovim defaults`. Squash trivial fixups locally and keep commits scoped to one logical change so flakes and locks stay reviewable. Pull requests should describe the motivation, link any relevant tasks or issues, note affected hosts, and include screenshots for UI-facing tweaks (such as desktop theming).

## Secrets & Security
Always enter `nix develop` so the `sops-import-keys-hook` loads keys from `keys/hosts` and `keys/users` before editing secrets. Modify encrypted files with `sops secrets/<file>`; the `.sops.yaml` rules ensure the correct key is used, so do not re-encrypt manually. Store non-secret configuration alongside the relevant module instead of in `secrets/`, and purge obsolete secrets to avoid shipping unused credentials.
