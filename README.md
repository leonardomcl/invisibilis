# 🛡️ Invisibilis - Steganography Tool

![Delphi](https://img.shields.io/badge/Made%20with-Delphi-critical.svg) 
![Platform](https://img.shields.io/badge/Platform-Windows%20x64-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

O **Invisibilis** é uma ferramenta de esteganografia moderna desenvolvida em **Delphi (FireMonkey)**. Ele permite ocultar mensagens de texto dentro de imagens digitais sem causar alterações perceptíveis ao olho humano, utilizando a técnica de manipulação do bit menos significativo (**LSB**).

---

## ✨ Funcionalidades

* **Algoritmo LSB Profissional:** Injeção de dados nos canais RGB (Red, Green, Blue).
* **Criptografia de Ponta:** Proteção via **AES-128** através da biblioteca LockBox 3.
* **Remoção de Metadados:** Limpa automaticamente tags EXIF/GPS para garantir total privacidade.
* **Cálculo Dinâmico:** O sistema informa em tempo real quantos bytes restam conforme você digita.
* **Interface Fluida:** Operações assíncronas (Threading) para não travar a interface durante o processamento de imagens grandes.

---

## 🛠️ Como Funciona?

A esteganografia LSB funciona substituindo o último bit de cada byte de cor de um pixel pelo bit da sua mensagem criptografada.



### Fluxo de Trabalho:
1.  **Input:** O texto é convertido para bytes e criptografado com sua senha.
2.  **Processamento:** O Invisibilis percorre a matriz de pixels da imagem original.
3.  **Injeção:** Os bits são distribuídos nos bits menos significativos da imagem.
4.  **Output:** Uma nova imagem é gerada em formato **PNG** (Lossless).

---

## 🚀 Como Executar o Projeto

### Requisitos
* Delphi 11 Alexandria ou superior.
* Biblioteca [LockBox 3](https://github.com/SeanBDurkin/tplockbox).

### Compilação
1.  Clone o repositório:
2.  Abra o arquivo `Invisibilis.dpr` no Delphi.
3.  Selecione a plataforma `Windows 64-bit`.
4.  Pressione `Shift + Ctrl + F9` para compilar.

---

## ⚠️ Observações Importantes

> [!IMPORTANT]
> Para que a mensagem não seja perdida, a imagem gerada **nunca** deve ser convertida para JPG ou enviada por aplicativos que comprimem a mídia (como WhatsApp ou Facebook), pois a compressão destrói os bits escondidos. Use sempre formatos sem perdas (PNG/BMP)

---
*Protegendo informações um bit de cada vez.*
