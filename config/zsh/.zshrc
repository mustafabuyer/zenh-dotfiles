# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/Desktop/ProjectZenh/rand-quote-terminal/:$PATH"

ZSH_THEME="agnosterzak"

plugins=(
    git
    archlinux
    zsh-autosuggestions
    zsh-syntax-highlighting
)


source $ZSH/oh-my-zsh.sh

# Check archlinux plugin commands here
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/archlinux

# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
#pokemon-colorscripts --no-title -s -r #without fastfetch
#pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -

# fastfetch. Will be disabled if above colorscript was chosen to install
#fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

# Set-up icons for files/directories in terminal using lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory




# ~/.zshrc dosyasının sonuna ekle

# Terminal başlangıcında rastgele GIF göster - ERROR HANDLING VERSION
# Sadece interaktif shell'lerde çalıştır
if [[ $- == *i* ]] && [ -z "$TMUX" ] && [ -z "$VIM" ]; then
    # Rastgele GIF seç ve göster
    if [ -d "/home/eren/sprite_gifs_fixed" ]; then
        # ls komutu ile GIF dosyalarını listele
        gif_files=($(ls "/home/eren/sprite_gifs_fixed/"*.gif 2>/dev/null))
        
        if [ ${#gif_files[@]} -gt 0 ]; then
            # Maksimum 5 deneme yap (hatalı GIF'ler için)
            attempts=0
            max_attempts=5
            
            while [ $attempts -lt $max_attempts ]; do
                random_gif="${gif_files[RANDOM % ${#gif_files[@]}]}"
                
                # Kitty ile göstermeyi dene
                if kitty +kitten icat --align left "$random_gif" 2>/dev/null; then
                    # Başarılı oldu, çık
                    break
                else
                    # Hata varsa başka GIF dene
                    ((attempts++))
                fi
            done
            
            # Hiçbiri çalışmadıysa basit mesaj göster
            if [ $attempts -eq $max_attempts ]; then
                echo "🎬 Animasyon yüklenemedi (format sorunu)"
            fi
        fi
    fi
fi
if [[ $- == *i* ]] && [ -z "$TMUX" ] && [ -z "$VIM" ]; then
    gif_files=(~/.config/terminal-gifs/*.gif)
    if [ ${#gif_files[@]} -gt 0 ] && [ -f "${gif_files[0]}" ]; then
        random_gif="${gif_files[RANDOM % ${#gif_files[@]}]}"
        kitty +kitten icat --align left "$random_gif" 2>/dev/null
    fi
fi





function ayet_kutu_ustalt() {
  local ayet=$(grep -vE '^[+-] ' ~/Desktop/ProjectZenh/rand-quote-terminal/random_quotes.txt | shuf -n 1)
  echo "$ayet" > ~/Desktop/ProjectZenh/rand-quote-terminal/son_ayet.txt

  local term_width=$(tput cols)
  local color="%F{180}"
  local color2="%F{144}"	
  local reset="%f"
  local bold="%B"
  local unbold="%b"

  local iç_genişlik=$((term_width - 5))
  local kenar_uzunluk=$(((term_width - 41) / 2))
  local çizgi=$(printf '─%.0s' $(seq 1 $kenar_uzunluk))

  print -P "${bold}${color2}╭✧$çizgi ❀ ┈ ❁ ┈ ✿ ┈ ✧═✧  ☪  ✧═✧ ┈ ✿ ┈ ❁ ┈ ❀ $çizgi✧╮${reset}${unbold}"

  echo "$ayet" | fold -s -w $iç_genişlik | while IFS= read -r line; do
    local line_len=${#line}
    local pad_left=$(((iç_genişlik - line_len) / 2))
    local pad_right=$((iç_genişlik - line_len - pad_left))
    local boşluk_sol=$(printf ' %.0s' $(seq 1 $pad_left))
    local boşluk_sağ=$(printf ' %.0s' $(seq 1 $pad_right))
    print -P "${color2}╣ ${color}${boşluk_sol}${line}${boşluk_sağ} ${color2}╠${reset}"
  done

  print -P "${bold}${color2}╰✧════✧$çizgi┐ ╚═⚛═══❖═╗🜂🜃🜁🜃🜂╔═❖═══⚛═╝ ┌$çizgi✧════✧╯${reset}${unbold}"
}

ayet_kutu_ustalt
