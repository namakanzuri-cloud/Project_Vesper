# DEV GUIDELINES

Project Vesper は、Godot 4.7 / GDScript で作る 2.5D 見下ろしアクション戦闘プロトタイプです。

## プロジェクトの前提

- 基準エンジンは Godot 4.7 stable とする。
- メインの実行シーンは `scenes/Main.tscn` とする。
- 新規のゲーム実装は Godot 側のファイルを対象にし、過去の Unity 版ファイルは基本的に参考扱いにする。
- 現在の目標は「強敵1体と戦う 2.5D 見下ろしアクション戦闘」の最小プロトタイプを育てること。
- プロトタイプ段階では、最終アートや完成度よりも、すぐ触って検証できることを優先する。

## リポジトリ構成

- `project.godot`: Godot プロジェクト設定とメインシーン設定。
- `scenes/`: Godot のシーンファイル。
- `scripts/`: GDScript のゲームロジック、UI、カメラ、補助スクリプト。
- `README.md`: セットアップ、操作方法、現在の仕様を説明するユーザー向け文書。
- `Assets/`, `Packages/`, `ProjectSettings/`: 旧 Unity プロトタイプ由来のファイル。明示的な指示がない限り編集対象にしない。

## 実装ルール

- ゲームプレイ実装は GDScript で行う。
- Unity 版の逐語的な移植ではなく、Godot の Node / Scene 構成に合う自然な設計を優先する。
- 調整される可能性がある数値は、なるべく `@export` 変数にして Inspector から変更できるようにする。
- `Health`, `Stamina`, `PlayerController`, `EnemyController`, `CombatHitbox`, `CombatUI`, `CameraFollow` のように、責務ごとに小さく分ける。
- パリィ、ヒットストップ、カメラ揺れ、コンボ表示、ボス攻撃パターンなどを後から足しやすい構造を意識する。
- 正式アートがない間は、カプセルやボックスなどのプリミティブ表示でよい。
- 向きガイドなどの一時的なデバッグ表示は、テストプレイしやすくなるなら入れてよい。

## 入力ルール

- 操作は Input Map のアクション名で管理する。
- 現在想定しているアクション名:
  - `move_left`, `move_right`, `move_forward`, `move_back`
  - `dodge`
  - `parry`
  - `light_attack`, `heavy_attack`
  - `retry`
  - `debug_reset`
- `scripts/input_setup.gd` は、Input Map にイベントが未設定のとき、実行時にデフォルト入力を補う用途で使ってよい。

## 検証ルール

- 変更後、可能なら Godot 4.7 の headless 読み込み確認を行う。
- Godotが環境に存在しない場合は、検証不能だったことを報告する。
- ゲームロジックを変更した場合、可能なら小さなランタイム確認や自動確認も行う。
- GUI ツールの起動は、ユーザーが依頼または承認した場合のみ行う。
- このプロジェクトでは開発サーバーを起動しない。

## 安全ルール

- フォルダやファイルは、ユーザーの明示確認なしに削除しない。
- 旧 Unity 版ファイルは、ユーザーが明示的に依頼しない限り削除しない。
- API キーや外部サービスは、ユーザーの明示指示なしに使用しない。
- 要件があいまいで危険な判断が必要な場合は、推測で進めず質問する。

## 旧Unity版ファイルについて
- 旧Unity版ファイルは現時点では参考資料として残す。
- Godot版の基本戦闘が安定した段階で、別ブランチまたは archive/ に移動することを検討する。
- ただし、削除・移動はユーザー確認後に行う。

## 当面の設計方針

- プロトタイプは、すぐリトライできて検証しやすい状態を保つ。
- 直近で完了した要素:
  - プレイヤー攻撃の状態管理
  - 敵攻撃の予兆表示
  - 命中時のヒットストップ
  - 命中時のカメラ揺れ
  - 攻撃命中時の簡易VFX
  - 敵HP0時の勝利表示
  - プレイヤーのパリィ
  - コンボ表示
  - 敵攻撃タイプ追加 Phase 1（速い斬り / 遅延重斬り / 掴み）
  - 敵の仮腕・仮武器による構え表現
  - 敵攻撃シーケンス / コンボパターン Phase 1
  - 敵攻撃タイプ追加 Phase 2（アーマー叩きつけ / 後退フェイント攻撃）
  - 攻撃タイプごとの中断ルール調整
  - パリィ成功後の反撃強化
  - ジャスト回避
  - Flowの簡易表示
  - Parry Stock / Riposte / Vesper Counter
  - 敵AI Phase 3：距離別パターン選択 / 軽い対パリィ補正
  - Flow消費アクション / Vesper Art prototype
  - Just Dodge Counter Phase 1：ジャスト回避後の短時間受付、左クリック専用反撃、Flow/コンボ/簡易演出/デバッグ表示
  - Result Evaluation / Style Rank Phase 1：勝利時の簡易リザルト、戦闘統計、D〜VESPERランク表示
  - Combat Run Log / Result Debug Export Phase 1：勝利/死亡時のResult JSON生成、画面概要表示、Copy Result Logボタン/F9コピー
  - Rhythm Parry / Light Attack Deflect Phase 1: fast/light attack Deflect, Deflect chain, Flow bonus, parry fail recovery, Deflect stats / Run Log
- 次に価値が高い要素は、以下の順で実装する。
  1. 攻撃パターンの追加調整
  2. 敵AIの追加調整
  3. リザルト評価の調整 / 専用UI検討

## 当面禁止する実装:
- ランダムステージ生成
- 装備ドロップ
- 永続成長
- 複数キャラ実装
- 正式モデル前提の処理
- 大規模な状態管理フレームワーク
- 独自イベントバスや過剰な抽象化

## Enemy Motion Readability / Floor Telegraph Modes

- Treat floor telegraphs as debug/assist visuals. The intended readability direction is enemy body, arm, weapon, and stance motion first.
- Enemy floor telegraph modes are `FULL_DEBUG`, `MINIMAL`, and `OFF`; keep all three useful when changing enemy attacks.
- `MINIMAL` and `OFF` should remain viable for testing whether attack types are readable without relying on floor color.
- Preserve Fast Combo / Deflect rhythm unless a future task explicitly asks for timing rebalance.
- Treat Fast Combo Grab/Slam finishers as occasional punish options; Heavy Finish should remain the primary default ending.

- Blood Rend / Blood Scent prototype: Q follow-up after earned hit openings, separate blood-cost stats, Blood Scent clean-play reward, Result JSON fields.
