# Notes

## Grab multiple k/v secrets with range function
```
vault.hashicorp.com/agent-inject-secret-database-config.txt: "internal/database/config"
        vault.hashicorp.com/agent-inject-template-database-config.txt: |
          {{- with secret "internal/database/config" -}}
          {{ range $k,$v := .Data.data }}
          {{ $k }}="{{ $v }}" 
          {{ end }}
          {{- end }}
```