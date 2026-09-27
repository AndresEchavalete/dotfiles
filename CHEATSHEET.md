# Tu Nuevo Stack de Desarrollo TUI (Terminal User Interface)

Esta guía te ayudará a transformar tu terminal en un IDE completo, ultraligero y centrado en el teclado, reemplazando la necesidad de IntelliJ o PHPStorm.

## 🛠️ 1. Instalación de Herramientas Core

Primero, asegúrate de tener instaladas las herramientas base en tu sistema (ejemplo para Ubuntu/Debian, adapta según tu SO o usa Homebrew si usas Mac/Linuxbrew):

```bash
# 1. Instalar dependencias del sistema (Buscador rápido y ripgrep son clave para Neovim)
sudo apt install ripgrep fd-find xclip

# 2. Instalar Lazygit (Git interactivo)
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin

# 3. Instalar Lazydocker (Contenedores interactivos)
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

# 4. Instalar Neovim (Binario oficial precompilado para Linux x86_64)
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
# Asegúrate de agregar /opt/nvim-linux-x86_64/bin a tu PATH, por ejemplo:
# echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc
```

## 🚀 2. Configurar Neovim con LazyVim

Como no quieres perder tiempo configurando Neovim desde cero durante meses, usaremos **LazyVim**. Es una distribución oficial que viene con atajos pensados para reemplazar IDEs, pero sigue siendo 100% Neovim y personalizable.

```bash
# Haz backup de tu configuración actual (si la tienes)
mv ~/.config/nvim ~/.config/nvim.bak

# Clona el starter de LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

Al abrir `nvim` por primera vez, descargará automáticamente todos los plugins (interfaz bonita, autocompletado, explorador de archivos, integración con Lazygit, etc.).

### Añadir Soporte para Bases de Datos (Dadbod)

Para tener el equivalente a DataGrip o la pestaña de BD de IntelliJ, crea un archivo en `~/.config/nvim/lua/plugins/dadbod.lua` con este contenido:

```lua
return {
  {
    "tpope/vim-dadbod",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
    end,
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<cr>", desc = "Toggle DB UI" },
    },
  },
}
```

---

## 🗺️ 3. Chuleta de Uso Extendida (Cheatsheet)

La tecla `<leader>` en LazyVim por defecto es la tecla `Espacio` (Space).

### 📁 Búsqueda y Exploración de Archivos

| Atajo | Acción | Equivalente en IntelliJ |
| :--- | :--- | :--- |
| `Espacio` + `e` | Abre el árbol de archivos (Neo-tree). Usa `H` e `I` para ver ocultos e ignorados. | Project View (`Alt+1`) |
| `Espacio` + `Espacio` | **Buscador rápido de archivos** (Telescope) | Search Everywhere (`Shift, Shift`) |
| `Espacio` + `s` + `g` | **Buscar texto en todo el proyecto** (Live Grep) | Find in Files (`Ctrl+Shift+F`) |
| `Espacio` + `s` + `b` | Buscar texto en el archivo actual | Find (`Ctrl+F`) |
| `Espacio` + `f` + `r` | Archivos recientes | Recent Files (`Ctrl+E`) |

### 📑 Navegar entre Solapas (Buffers y Paneles)

En Neovim, las "solapas" se llaman Buffers.
LazyVim te las muestra arriba como si fueran pestañas.

| Atajo | Acción | Equivalente en IntelliJ |
| :--- | :--- | :--- |
| `Shift` + `H` | Ir a la solapa (buffer) anterior | Pestaña anterior (`Alt+Left`) |
| `Shift` + `L` | Ir a la solapa (buffer) siguiente | Pestaña siguiente (`Alt+Right`) |
| `Espacio` + `b` + `d` | **Cerrar la solapa actual** (Delete Buffer) | Cerrar pestaña (`Ctrl+W` / `Ctrl+F4`) |
| `Espacio` + `b` + `p` | Fijar solapa (Pin Buffer) | Pin Tab |
| `Ctrl` + `h/j/k/l` | Mover el cursor entre paneles divididos (splits) | Split Tabs movement |

### 🧠 Fluidez del Código, LSP y Navegación

LazyVim te da la experiencia completa de IntelliJ sin tocar el mouse.
¡Aprende a usar `Ctrl+O` y `Ctrl+I` para saltar hacia atrás y hacia adelante en el historial de navegación!

| Atajo | Acción | Equivalente en IntelliJ |
| :--- | :--- | :--- |
| `g` + `d` | **Ir a la definición** | Go to Definition (`Ctrl+Click`) |
| `g` + `I` | **Ir a la implementación** (muy útil en interfaces) | Go to Implementation (`Ctrl+Alt+Click`) |
| `g` + `y` | Ir a la definición del Tipo (Type Definition) | Type Definition (`Ctrl+Shift+B`) |
| `g` + `r` | **Ver todas las referencias** (usos) de la función | Find Usages (`Alt+F7`) |
| `Shift` + `K` | Mostrar documentación (Hover) sobre la variable/función | Quick Doc (`Ctrl+Q`) |
| `Ctrl` + `k` | *(En modo inserción)* Muestra la firma de la función (parámetros esperados) | Parameter Info (`Ctrl+P`) |
| `Ctrl` + `o` | **Volver atrás** (al archivo o línea de donde viniste) | Navigate Back (`Ctrl+Alt+Left`) |
| `Ctrl` + `i` | **Ir hacia adelante** (deshacer el volver atrás) | Navigate Forward (`Ctrl+Alt+Right`) |

### 🛠️ Refactorización y Errores

| Atajo | Acción | Equivalente en IntelliJ |
| :--- | :--- | :--- |
| `Espacio` + `c` + `r` | Renombrar variable/función en todo el proyecto | Rename (`Shift+F6`) |
| `Espacio` + `c` + `a` | **Acciones de código** (Fixes rápidos, importar librería, etc.) | Intention Actions (`Alt+Enter`) |
| `]d` / `[d` | Ir al siguiente / anterior error o advertencia en el archivo | Next Highlighted Error (`F2`) |
| `Espacio` + `x` + `x` | Mostrar lista de todos los problemas/errores del proyecto | Problems View (`Alt+6`) |

### 🌿 Git (Lazygit)

| Atajo | Acción |
| :--- | :--- |
| `Espacio` + `g` + `g` | Abre Lazygit. Usa `Espacio` para hacer stage, `c` para commit, `P` para push. |
| `Espacio` + `g` + `b` | Ver historia de Git del archivo actual (Blame) |

### 🗄️ Base de Datos (Dadbod UI)

| Atajo | Acción |
| :--- | :--- |
| `Espacio` + `D` | Abre el panel de BD. Escribe `A` para añadir conexión. |
| `<leader>S` | Ejecuta la query SQL bajo el cursor. |

---

## 📦 4. Cómo Exportar este Entorno (Dotfiles)

El método profesional (y el mejor) para sincronizar tu entorno de desarrollo es usar un repositorio en GitHub llamado **`dotfiles`**.

### Paso 1: Crea la estructura en tu casa

```bash

# 1. Ve a tu directorio principal y crea la carpeta
cd ~
mkdir -p ~/dotfiles/nvim/.config

# 2. Mueve tu configuración real de Neovim dentro de la carpeta dotfiles
mv ~/.config/nvim ~/dotfiles/nvim/.config/

# 3. Usa Stow para crear el enlace simbólico (symlink) de vuelta a ~/.config
sudo apt install stow
cd ~/dotfiles
stow nvim
```

Al hacer `stow nvim`, GNU Stow crea automáticamente un acceso directo en `~/.config/nvim` que apunta a `~/dotfiles/nvim/.config/nvim`. Neovim ni se entera de que lo cambiaste de lugar.

### Paso 2: Sube a GitHub

```bash
cd ~/dotfiles
git init
git add .
git commit -m "Mi entorno inicial de Neovim"
git branch -M main
# Crea un repo privado en github llamado 'dotfiles'
git remote add origin https://github.com/tu-usuario/dotfiles.git
git push -u origin main
```

### Paso 3: Replicar en la Oficina (¡Magia!)

Cuando llegues a tu host del trabajo, solo tienes que hacer:

```bash
cd ~
git clone https://github.com/tu-usuario/dotfiles.git
cd dotfiles
sudo apt install stow
stow nvim
```

Y listo. Cuando cambies un atajo o añadas un plugin en la oficina, haces `git push`. Llegas a casa, haces `git pull` en la carpeta `~/dotfiles` y **ambas máquinas estarán siempre idénticas.**
