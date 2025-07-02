# git-clean-all

Uma função Bash para automatizar a limpeza de branches órfãs (aquelas cujos remotes foram deletados) em múltiplos repositórios Git a partir de uma pasta base. O script traz alertas visuais usando emojis, lida com repositórios recém-inicializados e permite alterar o diretório de busca dos repositórios.

---

## ⚠️ Aviso de uso

> **ATENÇÃO:**  
> Use este script por sua conta e risco.  
> Antes de executar, revise o funcionamento e certifique-se de que compreende as ações realizadas, principalmente em repositórios com alterações não comitadas ou trabalho não salvo.  
> Não nos responsabilizamos por eventuais perdas, deleções acidentais ou danos nos repositórios.

---

## ✨ Funcionalidades

- **Busca recursiva:** Procura recursivamente todos os repositórios Git em um diretório base (varre todas as subpastas).
- Para cada repositório:
  - Faz `git fetch --all --prune` para atualizar referências remotas.
  - Detecta e avisa sobre alterações não comitadas antes de qualquer operação.
  - Tenta trocar para a branch `develop` ou `main` (se existirem).
  - Deleta branches órfãs (que perderam o remote) de forma segura.
  - Ignora repositórios sem commits, avisando o usuário.
  - Usa emojis para tornar a execução mais informativa e divertida.

---

## 🚀 Instalação

1. Copie o conteúdo do script `git-clean-all.sh` para o seu arquivo de configurações do terminal (`~/.bashrc`, `~/.zshrc`, etc).
2. Reinicie o terminal ou execute `source ~/.bashrc` (ou `source ~/.zshrc`).

---

## 🛠️ Uso

```bash
git-clean-all [diretorio_base]
```

- Se `diretorio_base` não for informado, será usado `~/Repositories` por padrão.
- O script procura recursivamente por repositórios Git dentro dessa pasta e todas as suas subpastas.
- Exemplo para rodar na pasta padrão:
  ```bash
  git-clean-all
  ```
- Exemplo para rodar em outro diretório:
  ```bash
  git-clean-all ~/meus-projetos
  ```

---

## 📋 O que o script faz em cada repositório?

- Exibe o caminho do repositório.
- Atualiza e limpa referências remotas.
- Mostra a branch atual e alerta se houver arquivos modificados e não comitados.
- Tenta trocar para a branch `develop` ou `main`.
- Lista e deleta branches locais órfãs (cujo remote já não existe).
- Ignora repositórios sem commits, avisando com emoji específico.

---

## 💡 Observações

- **Alterações não comitadas:** O script prossegue mesmo se houver alterações não comitadas, mas avisa o usuário antes.
- **Branches protegidas:** Nunca tenta deletar a branch atualmente ativa.
- **Branches com alterações não integradas:** Se a branch órfã tiver trabalho não integrado, o Git não permitirá a deleção (e o script avisa).
- **Repositórios sem commits:** São ignorados e informados no terminal.

---

## 🧹 Exemplos de saída

```
📁 Repository: /Users/usuario/Projects/meu-repo
🔄 Fetching and pruning remotes...
⚠️  Uncommitted changes detected in /Users/usuario/Projects/meu-repo on branch 'feature-x'. Attempting to continue anyway... 🛠️
🔀 Switching to 'develop' or 'main' branch if possible...
🗑️  Orphan branches to delete:
  ✔️ Deleted: feature/removida-no-remote 🧹
  ❌ Could not delete: bugfix/teste (it may have unmerged work) 🚫
-----------------------------------------------
```

---

## 🐞 Possíveis limitações

- Repositórios com configurações muito customizadas podem requerer ajustes.
- O script só lida com branches órfãs locais (não mexe em remotes).
- Não resolve conflitos de merge automaticamente.

---

## 📄 Licença

The GNU General Public License v3.0

---
