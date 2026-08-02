# Tarefa 6.0: Biometria iOS — Face ID + Keychain

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

No iOS, o refresh token passa a ser guardado no Keychain protegido por biometria (`@capgo/capacitor-native-biometric`): abrir o app com sessao ativa exige Face ID/Touch ID, e o desbloqueio e a propria recuperacao da credencial. Na web nada muda (acesso direto com sessao valida). Se a biometria falhar ou for cancelada, o app oferece login por senha.

<skills>
### Conformidade com Skills Padroes

- `ionic-design` — fluxo de desbloqueio sem telas intermediarias quando a biometria funciona.
- `vercel-react-best-practices` — bootstrap de sessao sem renders intermediarios desnecessarios.
- Convencao dos repositorios controlai: **comentarios de codigo em ingles**.
</skills>

<requirements>
- RF-3.2: abrir o app com sessao ativa exige Face ID/Touch ID antes de exibir dados.
- RF-3.3: dispositivos sem biometria (ex.: web) acessam direto com sessao valida.
- RF-3.4: biometria falha/cancelada → fallback para login por senha.
- UX: desbloqueio imediato ao abrir o app, sem telas intermediarias quando a biometria funciona.
</requirements>

## Subtarefas

- [ ] 6.1 Instalar/configurar `@capgo/capacitor-native-biometric` (Capacitor 8); `NSFaceIDUsageDescription` no `Info.plist`.
- [ ] 6.2 `biometricService`: deteccao de disponibilidade, `unlockWithBiometrics()` conforme interface da techspec.md.
- [ ] 6.3 `tokenStorage` nativo: refresh token no Keychain protegido por biometria (`setCredentials`/`getCredentials`); manter localStorage na web.
- [ ] 6.4 Bootstrap do `AuthContext` no iOS: sessao ativa → prompt Face ID → recupera refresh token → `POST /auth/refresh` → app desbloqueado.
- [ ] 6.5 Fallback: biometria cancelada/falha repetida → tela de login por senha (sessao preservada ate logout explicito ou refresh invalido).
- [ ] 6.6 Tratar credenciais invalidadas (reinstalacao do app, mudanca de biometria) → login por senha (risco documentado na techspec.md).
- [ ] 6.7 Testes (ver "Testes da Tarefa").

## Detalhes de Implementacao

Ver techspec.md, secoes "Visao Geral dos Componentes" (fluxo principal), "Interfaces Principais" (`unlockWithBiometrics`) e "Riscos Conhecidos" (Face ID + Keychain).

## Criterios de Sucesso

- iOS: abrir o app logado → Face ID → dados visiveis; cancelar → tela de senha.
- Web: comportamento inalterado (sem prompt biometrico).
- Reinstalacao/mudanca de biometria nao trava o app (cai no login por senha).
- `tsc`, `lint`, `build` e testes Vitest passando.

## Testes da Tarefa

- [ ] Unidade (Vitest): `biometricService` e `tokenStorage` nativo com plugin mockado (disponivel/indisponivel/falha/cancelado); logica de bootstrap do `AuthContext` por plataforma.
- [ ] Integracao: fluxo de desbloqueio simulado (mock do plugin) ate o refresh da sessao.
- [ ] Testes E2E: biometria nao e automatizavel — roteiro de validacao manual no device (documentar para o QA da Tarefa 9.0).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/Volumes/SSD480GB/projects/controlai-frontend/package.json` (`@capgo/capacitor-native-biometric`)
- `/Volumes/SSD480GB/projects/controlai-frontend/ios/App/App/Info.plist`
- `/Volumes/SSD480GB/projects/controlai-frontend/src/services/biometricService.ts` (novo), `src/services/tokenStorage.ts`, `src/context/AuthContext.tsx`
