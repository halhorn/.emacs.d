# .emacs.d
わたしの emacs.d

# Install
既存の emacs.d を置き換えるので各自の責任でお願いしますよ。

```sh
cd
mv .emacs.d .emacs.d.bak
git clone git@github.com:halhorn/.emacs.d.git
emacs
```
最初の起動時に自動的にいろいろインストールされます。

# プロジェクト依存
python の保存時自動テストは、プロジェクトのディレクトリ構成に依存しています。
以下のように、モジュール本体のパスに test/ プレフィクスをつけたパスが対応するテストモジュールになるディレクトリ構成を想定しています。

```
moge/fuga/hogehoge.py  # モジュール本体
test/moge/fuga/hogehote.py  # 上記のモジュールのテスト
```

また、 test/run.py が存在し、以下のコマンドでテストを実行できることを想定しています。

```sh
python -m test.run moge/fuga/hogehoge.py
# or
python -m test.run test/moge/fuga/hogehoge.py
```
これは以下のように実装できます。

```py3
# test/run.py
from unittest import TestLoader
from unittest import TextTestRunner
import sys
import os

project_dir = os.path.join(os.path.dirname(__file__), '..')


def main(path=None):
    if path:
        tests = _get_tests_from_file_path(path)
    else:
        tests = TestLoader().discover(os.path.join(project_dir, 'test/'), pattern='*.py', top_level_dir=project_dir)

    return_code = not TextTestRunner().run(tests).wasSuccessful()
    sys.exit(return_code)


def _get_tests_from_file_path(path):
    if not path.endswith('.py'):
        raise Exception('test file path should not dir path')

    # path は test/hoge/fuga.py などで与えられる
    path = os.path.relpath(path, project_dir)
    if not path.startswith('test/'):
        path = 'test/' + path

    # test.hoge.fuga に変換
    module_name = path.replace('.py', '').replace('/', '.')
    return TestLoader().loadTestsFromName(module_name)


if __name__ == '__main__':
    args = sys.argv
    path = '.'
    if len(args) > 1:
        main(args[1])
    else:
        main()
```