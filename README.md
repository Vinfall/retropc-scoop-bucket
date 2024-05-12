# RetroPC scoop bucket

NEC PC-98x1 シリーズのエミュレータを中心とした [Scoop](https://scoop.sh) バケツです。Scoop は Windows 用のコマンドラインインストーラです。

このバケツには、オープンソースソフトウェアやフリーウェア以外のソフトウェアが多く含まれています。また、マニフェスト中のライセンス記載は参考です。各ソフトウェアのライセンスを各人でご確認のうえ、ご利用いただけますようお願いいたします。

## 使い方

1. Scoop をインストールする

    PowerShell で Scoop をインストールしてください。

    ```powershell
    > Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    > irm get.scoop.sh | iex
    ```

1. このバケツを追加する

    scoop にこのバケツを追加してください。

    ```powershell
    > scoop bucket add retropc https://github.com/gsminek/retropc-scoop-bucket.git
    ```

### 各機種用のイメージなど

各機種のバイナリやディスクイメージは、machine パッケージの presist ディレクトリにコピーしています。

例:

- ${scoopdir}/persist/
    - machine-dos/
        - msdos/
            - dosbin
                - MS-DOS バイナリ
            - dosvbin
                - DOS/V バイナリ
        - msdos-fdd/
            - FDD イメージ
        - msdos-hdd/
            - HDD イメージ
    - machine-msx/
    - machine-pc98/
    - machine-x68k/

## 留意事項

- マニフェストを削除しても、persist フォルダ内のファイルは削除されません。マニフェストのアップデートでも維持されます。適切な保管がされていない場合は、お知らせください。
