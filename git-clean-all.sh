git-clean-all() {
  # Define o diretório base como o primeiro argumento, ou usa ~/Repositories por padrão.
  local base_dir="${1:-$HOME/Repositories}"
  local repos

  # Busca todos os diretórios que possuem um subdiretório .git, ignorando outros arquivos e diretórios.
  repos=($(find "$base_dir" -type d -name ".git" -prune | xargs -n1 dirname))

  # Para cada repositório encontrado:
  for repo in "${repos[@]}"; do
    echo "📁 Repositório: $repo"
    # Entra no diretório do repositório. Se falhar, ignora e vai para o próximo.
    cd "$repo" || continue

    # Atualiza informações dos remotos e remove referências obsoletas.
    echo "🔄 Buscando e limpando remotos..."
    git fetch --all --prune

    # Verifica se o repositório possui commits (HEAD válido).
    if git rev-parse --verify HEAD >/dev/null 2>&1; then
      current_branch=$(git rev-parse --abbrev-ref HEAD)
    else
      current_branch="(sem commits)"
      echo "🚫 O repositório '$repo' não possui commits. Pulando limpeza de branches. ⏭️"
      echo "-----------------------------------------------"
      continue
    fi

    # Alerta sobre alterações não comitadas/adicionadas, mostrando a branch atual.
    if [[ -n $(git status --porcelain) ]]; then
      echo "⚠️  Alterações não comitadas detectadas em $repo na branch '$current_branch'. Tentando continuar assim mesmo... 🛠️"
    fi

    # Tenta trocar para a branch 'develop' ou 'main', se existirem.
    echo "🔀 Alternando para a branch 'develop' ou 'main', se possível..."
    git checkout develop 2>/dev/null || git checkout main 2>/dev/null

    local branches=()
    # Busca todas as branches locais órfãs (que apontam para remotes removidos).
    # Usa 'git branch -vv' e filtra as que possuem ': gone]' na descrição.
    while IFS= read -r branch; do
      clean_branch="$(echo "$branch" | sed 's/^\* //;s/^[[:space:]]*//;s/[[:space:]]*$//')"
      if [[ -n "$clean_branch" && "$clean_branch" != "*" ]]; then
        branches+=("$clean_branch")
      fi
    done < <(git branch -vv | awk '/: gone]/{print $1}')

    # Se não houver branches órfãs, avisa o usuário.
    if [[ ${#branches[@]} -eq 0 ]]; then
      echo "✨ Nenhuma branch órfã encontrada. 🍃"
    else
      echo "🗑️  Branches órfãs a serem deletadas:"
      # Para cada branch órfã encontrada, tenta deletar (exceto a branch atual).
      for branch in "${branches[@]}"; do
        # Não tenta deletar a branch atualmente checada.
        if [[ "$branch" != "$(git rev-parse --abbrev-ref HEAD)" ]]; then
          if git branch -d "$branch"; then
            echo "  ✔️ Deletada: $branch 🧹"
          else
            echo "  ❌ Não foi possível deletar: $branch (pode ter alterações não mescladas) 🚫"
          fi
        else
          echo "  ⏭️  Pulando a branch atual: $branch 🚦"
        fi
      done
    fi
    echo "-----------------------------------------------"
  done

  # Volta para o diretório home ao final (por conveniência).
  cd ~
  echo "✅ Todos os repositórios processados! 🎉"
}