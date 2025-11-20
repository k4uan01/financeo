# Como Instalar Java para Gerar Keystore

## Entendendo as Opções

Você precisa do **Java JDK** para usar o `keytool` (ferramenta que gera a keystore). Existem duas formas de obter o Java:

## Opção 1: Android Studio (Recomendado) ✅

### Por que Android Studio?

1. **Já inclui o Java JDK** - Não precisa instalar Java separadamente
2. **Necessário para Flutter/Android** - Você vai precisar mesmo para desenvolver
3. **Configuração automática** - Tudo funciona junto

### Como funciona:

- Quando você instala o Android Studio, ele instala o Java JDK automaticamente
- O Java fica dentro da pasta do Android Studio
- Você só precisa adicionar ao PATH do sistema (temos script para isso!)

### Passos:

1. **Baixe o Android Studio:**
   - Link: https://developer.android.com/studio
   - É gratuito e oficial do Google

2. **Instale normalmente:**
   - Siga o instalador
   - Ele vai instalar o Java automaticamente

3. **Adicione ao PATH:**
   ```powershell
   .\scripts\add_java_to_path.ps1
   ```
   - Este script encontra o Java do Android Studio automaticamente
   - Adiciona ao PATH para você poder usar `keytool` em qualquer lugar

4. **Feche e reabra o terminal**

5. **Teste:**
   ```powershell
   keytool -help
   ```

### Onde o Java fica:

Após instalar o Android Studio, o Java normalmente fica em:
- `C:\Users\SeuUsuario\AppData\Local\Android\Sdk\jbr\bin\`
- Ou: `C:\Program Files\Android\Android Studio\jbr\bin\`

O script `add_java_to_path.ps1` encontra automaticamente!

---

## Opção 2: Java JDK Separado (Alternativa)

### Use esta opção apenas se:

- Você **não vai desenvolver para Android/Flutter**
- Você **só precisa do Java** para gerar a keystore
- Você já tem outra forma de desenvolver (sem Android Studio)

### Passos:

1. **Baixe o Java JDK:**
   - Link: https://adoptium.net/temurin/releases/
   - Escolha: **Windows x64** (ou a versão do seu sistema)
   - Versão recomendada: **JDK 21** ou **JDK 17**

2. **Instale normalmente:**
   - Execute o instalador
   - Siga as instruções

3. **Adicione ao PATH:**
   ```powershell
   .\scripts\add_java_to_path.ps1
   ```
   - O script encontra e adiciona automaticamente

4. **Feche e reabra o terminal**

5. **Teste:**
   ```powershell
   keytool -help
   ```

---

## Qual Escolher?

### Escolha Android Studio se:
- ✅ Você está desenvolvendo app Flutter/Android
- ✅ Você quer tudo configurado automaticamente
- ✅ Você vai precisar do Android Studio mesmo

### Escolha Java Separado se:
- ✅ Você não vai usar Android Studio
- ✅ Você só precisa do Java para gerar a keystore
- ✅ Você prefere instalação mais leve

---

## Resumo Rápido

**Para Flutter/Android (recomendado):**
```
1. Instalar Android Studio → https://developer.android.com/studio
2. Executar: .\scripts\add_java_to_path.ps1
3. Pronto! Java já está disponível
```

**Apenas Java:**
```
1. Instalar JDK → https://adoptium.net/temurin/releases/
2. Executar: .\scripts\add_java_to_path.ps1
3. Pronto!
```

---

## Depois de Instalar

Após instalar qualquer uma das opções:

1. **Adicione ao PATH:**
   ```powershell
   .\scripts\add_java_to_path.ps1
   ```

2. **Gere a keystore:**
   ```powershell
   .\scripts\generate_keystore.ps1
   ```

3. **Configure o projeto:**
   - Crie o arquivo `android/key.properties`
   - Veja [KEYSTORE_SETUP.md](./KEYSTORE_SETUP.md)

---

## Dúvidas Frequentes

**P: Preciso instalar Android Studio E Java separado?**
R: **NÃO!** O Android Studio já vem com Java. Escolha um ou outro.

**P: Já tenho Android Studio instalado, preciso fazer algo?**
R: Só precisa adicionar ao PATH:
```powershell
.\scripts\add_java_to_path.ps1
```

**P: O script encontra o Java automaticamente?**
R: Sim! O script `add_java_to_path.ps1` procura em todos os locais comuns e você só escolhe qual usar.

**P: Posso usar o keytool sem adicionar ao PATH?**
R: Sim! Use o script `generate_keystore.ps1` que encontra o keytool automaticamente, mesmo sem estar no PATH.

