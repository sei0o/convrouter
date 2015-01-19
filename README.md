# convrouter

convert + router = convrouter

ファイルの変換経路を教えてくれます

# install
``` bash
$ git clone https://github.com/sei0o/convrouter.git
```
また、`.bash_profile`や`.bashrc`とかにも
``` bash
export PATH=$PATH:(インストールしたパス)
```
と追加してください。(Homebrewに追加する方法知らない)

# depend
[clier gem](http://github.com/sei0o/clier)に依存しています

# routes.yml

なお、routes.yml内でのファイル形式名は統一してください(jpg, jpegなど。)
別に拡張子を書かなくても良いです(GIFをanimate_gif, gifに分けて区別するなど)

``` yaml
routes:
  (ツール/サイトの名称):
    import:
      - jpg
      - bmp
      - tiff
      ... (のように、そのツールがimportできるファイル形式を書いてください)
    export:
      - png
      - gif
      - jpg
      ... (のように、そのツールがexportできるファイル形式を書いてください)
```