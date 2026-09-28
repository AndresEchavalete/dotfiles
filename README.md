# Mis Dotfiles (Gestión con GNU Stow)

Este repositorio contiene la configuración centralizada de mi entorno de desarrollo. Utilizo **GNU Stow** para enlazar automáticamente las configuraciones desde este repositorio hacia mi directorio personal (`~`), permitiéndome mantener sincronizados múltiples equipos (casa y oficina).

## 🧠 Filosofía de Stow

Stow funciona mediante "paquetes". Cada carpeta en la raíz de este repositorio es un paquete (ej: `nvim`, `agentes`, `terminal`). 
La regla de oro es: **La estructura de carpetas dentro de un paquete debe replicar la estructura partiendo desde tu `$HOME`.**

Por ejemplo, si la configuración de Neovim vive en `~/.config/nvim`, en este repositorio debe existir en `nvim/.config/nvim`.

## 🚀 Cómo instalar este entorno en una máquina nueva

1. Clona el repositorio en tu `$HOME`:
   ```bash
   cd ~
   git clone https://github.com/tu-usuario/dotfiles.git
   ```
2. Instala GNU Stow:
   ```bash
   sudo apt install stow  # En Debian/Ubuntu
   ```
3. Entra a la carpeta y activa ("stow") los paquetes que quieras:
   ```bash
   cd ~/dotfiles
   stow nvim
   stow agentes
   ```

*(Nota: Si Stow lanza un error diciendo que un archivo ya existe, debes borrar o mover el archivo original en tu `$HOME` antes de ejecutar el comando).*

## 📦 Cómo agregar un nuevo paquete a los dotfiles

Si quieres empezar a versionar la configuración de una nueva herramienta (por ejemplo, tus agentes de Antigravity), sigue estos pasos:

1. Crea la estructura del paquete dentro de `dotfiles`:
   ```bash
   mkdir -p ~/dotfiles/agentes/.gemini
   ```
2. Mueve la configuración real desde tu sistema hacia el paquete:
   ```bash
   mv ~/.gemini/config ~/dotfiles/agentes/.gemini/
   mv ~/.claude.json ~/dotfiles/agentes/
   ```
3. Activa el paquete con Stow para que cree el enlace simbólico (symlink) de regreso:
   ```bash
   cd ~/dotfiles
   stow agentes
   ```
4. Haz un commit y súbelo a Git:
   ```bash
   git add agentes/
   git commit -m "feat: agrego config de agentes y skills"
   git push
   ```

## 🔒 Seguridad: Cómo aislar archivos confidenciales (Ej: Tokens de IA)

Nunca debes versionar en Git archivos que contengan tokens, API keys o métricas ligadas a la facturación de tu empresa (como `~/.claude.json` o `mcp_config.json`). 

Stow y Git funcionan de forma independiente. Para mantener tu configuración segura y aislada por entorno:

1. **Usa el `.gitignore` del repositorio:**
   Mueve el archivo confidencial a tu paquete en dotfiles para que Stow lo enlace localmente a tu terminal, pero ignóralo en Git para que nunca se suba a tu repositorio (ni público ni privado).
   ```bash
   echo ".claude.json" >> ~/dotfiles/.gitignore
   echo "mcp_config.json" >> ~/dotfiles/.gitignore
   ```
   *De esta forma, en tu máquina del trabajo tendrás un archivo local `.claude.json` (que tu empresa paga) y en tu casa tendrás el tuyo personal. Ambos funcionarán, pero nunca se pisarán ni subirán a Git.*

2. **Usa archivos locales para variables de entorno (`.bashrc.local`):**
   Si exportas claves de API en tu terminal (`export ANTHROPIC_API_KEY=...`), **no** las pongas en el `.bashrc` que está en este repositorio. 
   En tu `.bashrc` principal agrega estas líneas al final:
   ```bash
   if [ -f ~/.bashrc.local ]; then
       source ~/.bashrc.local
   fi
   ```
   Luego, en cada computadora, crea manualmente un `~/.bashrc.local` (fuera de Stow) con las claves específicas de ese entorno.

## 🗑️ Cómo desvincular un paquete (Unstow)
Si ya no quieres que una herramienta use la configuración de este repositorio, puedes deshacer el symlink con la opción `-D`:
```bash
cd ~/dotfiles
stow -D nvim
```
*(Esto solo borra el acceso directo en tu sistema, los archivos siguen a salvo dentro de la carpeta `~/dotfiles`).*
