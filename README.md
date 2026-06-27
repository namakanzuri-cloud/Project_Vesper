# Project Vesper

Project Vesper は、Godot 4.7 / GDScript で作る 2.5D 見下ろしアクション戦闘プロトタイプです。

## 目的

強敵1体と戦うスタイリッシュアクションの最小試作です。
過去に作った Unity 版プロトタイプのプレイ感を参考にしつつ、Godot の Node / Scene 構成に合わせて作り直しています。

正式な3Dモデルやアニメーションはまだ使わず、カプセルやボックスなどの仮モデルで、まずは素早くテストプレイできることを優先しています。

## 戦闘設計メモ

Project Vesper の戦闘は、雑魚を大量に倒すハクスラよりも、
強敵1体〜少数精鋭との読み合いを重視する。

重視する要素:
- 敵の攻撃予兆を見て避ける
- 敵の構えや武器位置から攻撃タイプを読む
- 攻撃の後隙を狙って反撃する
- 遅い攻撃の予兆中に差し込みで崩す
- スタミナを管理して攻めすぎを防ぐ
- パリィやジャスト回避で高リターンを得る
- 短い戦闘でも手応えがあることを優先する

## 現在の機能

- 3D空間を使った 2.5D 見下ろしアリーナ
- カプセル表示のプレイヤーと敵
- プレイヤーと敵の向きが分かる簡易ガイド表示
- 敵カプセルに仮の腕・武器を追加し、構えで攻撃タイプを見分ける表示
- `WASD` 移動
- プレイヤーが移動方向を向く
- `Camera3D` が斜め上からプレイヤーを追従
- `Space` 回避ダッシュ
- 回避開始直後、敵攻撃 active 中の危険範囲で成立するジャスト回避
- `E` パリィ（短い受付時間 / 後隙）
- 左クリック通常攻撃（短い予備動作 / 攻撃判定 / 後隙）
- Right click is reserved for Riposte / Vesper Counter / Vesper Art; basic heavy attack is disabled.
- `VESPER ART` はFlowを消費する高威力の一撃
- Riposte / Vesper Counter の受付中は、Flow満タンでもそちらが優先される
- Vesper Art命中時に強いヒットストップ、カメラ揺れ、簡易VFX、`VESPER ART!` 表示が出る
- プレイヤーHP、敵HP、スタミナ
- 攻撃、回避、パリィによるスタミナ消費
- 時間経過によるスタミナ回復
- 敵の接近と複数攻撃パターンからの重み付き選択
- 敵AIがプレイヤーとの距離に応じて攻撃パターンを選び分ける
- 近距離では速い斬り、掴み、短い圧力が出やすい
- 中距離では遅延重斬り、後退フェイント、アーマー叩きつけ絡みが出やすい
- 遠距離では遅延重斬り、後退フェイントに候補が絞られる
- `Parry Stock` が高いとき、敵が掴み・アーマー・フェイントを少し選びやすくなる
- 同じ攻撃パターンの連発を抑える
- 敵の速い斬り（短い予兆 / 低〜中ダメージ / パリィ可能 / 中断不可）
- 敵の遅延重斬り（長い予兆 / 高めダメージ / パリィ可能 / 指定された予兆時間帯だけ差し込み中断可能）
- 敵の掴み（近距離 / 中〜高ダメージ / パリィ不可 / 中断不可 / 回避や距離取りで対応）
- 敵のアーマー叩きつけ（長い予兆 / 高ダメージ / パリィ不可 / 中断不可 / 回避後に反撃しやすい長めの後隙）
- Blue telegraph slash: same Deflect-style attack family as fast slash, with matched timing and no retreat movement
- 攻撃タイプごとの中断可否、差し込み可能時間帯、強攻撃要求、スタン時間の調整
- 敵攻撃シーケンス / コンボパターン Phase 2
- Fast Combo: 速い斬り → 速い斬り → 速い斬り → 遅延重斬り
- Grab Mix: 速い斬り → 掴み
- Simple Pressure: 速い斬り → 速い斬り
- Pressure into Slam: 速い斬り → 速い斬り → アーマー叩きつけ
- Slash Slam Mix: 速い斬り → アーマー叩きつけ
- 攻撃タイプごとの床予兆の色・サイズによる補助表示
- 遅延重斬りの予兆中、設定された中断可能時間帯にプレイヤー攻撃を当てると `INTERRUPT!` 表示と短時間スタン
- 速い斬り、掴み、アーマー叩きつけは差し込み中断不可
- Fast/light Deflect attacks use the same Deflect-style parry response; delayed heavy still stops the enemy and grants Riposte Ready.
- 掴みとアーマー叩きつけはパリィ active 中でも成功扱いにせず、命中時は通常被弾として扱う
- Normal attacks, Riposte / Vesper Art, and enemy attacks use hit stop
- Normal attacks, Riposte / Vesper Art, and enemy attacks use camera shake
- Normal attacks, Riposte / Vesper Art, and enemy attacks use simple VFX
- パリィ成功時の強めのヒットストップ、カメラ揺れ、簡易VFX、`PARRY!` 表示
- ジャスト回避成功時の軽いヒットストップ、カメラ揺れ、専用簡易VFX、`JUST DODGE!` 表示
- ジャスト回避成功時のコンボ加算 / コンボタイマー延長
- パリィ成功で `Parry Stock` が増え、最大3まで蓄積
- Right click is reserved for Riposte / Vesper Counter / Vesper Art; basic heavy attack is disabled.
- `Parry Stock` 最大時の Riposte は `VESPER COUNTER` になり、より高いダメージと強い演出を出す
- Riposte / Vesper Counter 命中時に Flow、コンボ、ヒットストップ、カメラ揺れ、簡易VFXが強化される
- `Just Dodge Counter`: ジャスト回避成功後、短時間だけ左クリックで専用カウンター攻撃を出せる
- `Just Dodge Counter` は通常攻撃より強く、Riposte / Vesper Counter より控えめな反撃として機能する
- `Just Dodge Counter` 命中時に Flow、コンボ、ヒットストップ、カメラ揺れ、簡易VFXが発生する
- Flow increases from successful actions and no longer decreases from taking damage.
- 攻撃命中とパリィ成功で増えるコンボ表示（`GOOD` / `STYLISH` / `VESPER` の簡易評価）
- HP / スタミナの簡易HUD
- プレイヤー死亡時の死亡表示
- 敵HP0時の勝利表示
- 勝利時に Clear Time、Damage Taken、Hit Taken、Max Combo、Parry Count、Just Dodge Count、Interrupt Count などをまとめた簡易リザルトを表示する
- 勝利/死亡時に直近戦闘結果ログを JSON 形式で生成し、画面の `Copy Result Log` ボタンまたは `F9` でクリップボードへコピーできる
- Result JSON には Rank、Score、Clear Time、Damage Taken、Max Combo、Parry Count、Just Dodge Count、Interrupt Count、Vesper Art Hit などが含まれ、テストプレイ結果を共有・分析しやすい
- 戦闘内容に応じて `D` / `C` / `B` / `A` / `S` / `VESPER` のスタイルランクを表示する
- Flow、Riposte / Vesper Counter、Just Dodge Counter、Vesper Art などの成功行動がリザルト評価に反映される
- リトライとデバッグリセット

## Rhythm Parry / Light Attack Deflect Phase 1

- Some fast/light enemy attacks now resolve as `DEFLECT` on parry success instead of stopping the enemy.
- Deflect success clears player parry recovery/cooldown immediately, so repeated parries can chain.
- Deflect grants Flow, and chained Deflects add a small Flow bonus.
- Delayed heavy still uses normal parry behavior: enemy stun, Riposte Ready, and Parry Stock.
- Fast/light Deflect attacks use one blue telegraph language, shared timing, and shared parry response for a steadier rhythm.
- Grab and armor slam remain non-parry success cases.
- Parry whiffs now enter a short vulnerable recovery.
- Result / Run Log JSON now includes `rhythmParryCount`, `deflectCount`, `maxDeflectChain`, and `parryFailCount`.

## File Structure

- `project.godot`: Godot project settings
- `DEV_GUIDELINES.md`: development rules and project guidelines
- `scenes/Main.tscn`: main runnable scene
- `scenes/Player.tscn`: player scene
- `scenes/Enemy.tscn`: enemy scene
- `scenes/UI.tscn`: HUD / victory / death overlay scene
- `scenes/HitVfx.tscn`: simple hit VFX scene
- `scripts/main.gd`: combat reset and result flow
- `scripts/player_controller.gd`: player input and combat actions
- `scripts/enemy_controller.gd`: enemy AI and attack patterns
- `scripts/health.gd`: HP management
- `scripts/stamina.gd`: stamina management
- `scripts/camera_follow.gd`: camera follow / shake
- `scripts/combat_hitbox.gd`: shape-based hit detection
- `scripts/combo_tracker.gd`: combo tracking
- `scripts/flow_tracker.gd`: Flow management
- `scripts/combat_stats.gd`: combat stats / style rank evaluation
- `scripts/hit_stop.gd`: short hit-stop control
- `scripts/hit_vfx.gd`: simple hit VFX logic
- `scripts/combat_ui.gd`: HUD and debug display
- `scripts/input_setup.gd`: default input setup


1. Godot 4.7 でこのフォルダを開く。
2. `scenes/Main.tscn` を開く。
3. Play を押す。

`project.godot` で `scenes/Main.tscn` をメインシーンに設定しているので、プロジェクト実行でも起動できます。

## 操作方法

- `WASD`: 移動
- `Space`: 回避ダッシュ（敵攻撃 active 中に紙一重で避けるとジャスト回避が発生）
- `E`: パリィ
- 左クリック: 通常攻撃
- Right click: Riposte / Vesper Counter when ready, otherwise `VESPER ART` when Flow is full
- `R`: 死亡後・勝利後リトライ
- `F5`: いつでもデバッグリセット
- `Copy Result Log` ボタン: 直近の戦闘結果JSONをクリップボードへコピー
- `F9`: リザルト表示中に直近の戦闘結果JSONをコピー

入力アクションは `project.godot` の Input Map で管理します。
`project.godot` 側にイベントが未設定の場合でも、`scripts/input_setup.gd` が実行時にデフォルト入力を補います。

## 既知の制限

- 正式な3Dモデルやアニメーションは未実装です。
- 敵の腕や武器はプリミティブによる仮表示です。正式モデル、正式アニメーション、武器軌跡はまだありません。
- アーマー叩きつけや後退フェイント攻撃の構え・発光・床予兆は、仮モデル用の簡易表現です。
- プレイヤー攻撃は、仮モデル段階の球形判定です。正式な武器軌跡や攻撃アニメーションはまだありません。
- 敵攻撃パターンは `enemy_controller.gd` 内の仮定義です。敵AIはまだ簡易的な重み付き選択であり、正式な行動ツリーや高度な状況判断AIではありません。
- 距離別選択、同一パターン抑制、軽い対パリィ補正は仮調整です。
- 攻撃判定は `CombatHitbox` の球形判定で、正式な武器軌跡はまだありません。
- 敵攻撃予兆は、球形判定の足元投影に合わせた仮表示です。正式な扇形やアニメーション付き予兆はまだありません。
- 複雑な行動ツリー、状況判断AI、攻撃パターンの外部データ化は未実装です。
- 突進攻撃、範囲攻撃は未実装です。
- ジャスト回避は実装済みですが、現状は敵攻撃判定の球形範囲と近接マージンを使った仮判定です。正式な武器軌跡やアニメーション連動判定はまだありません。
- Flowは成功行動で増え、Vesper Artで消費できる戦闘資源です。勝利時の簡易リザルト評価にも反映されます。
- `Just Dodge Counter` は実装済みです。正式な回避演出 / 専用アニメーションは未実装で、既存VFX流用の仮演出です。
- Riposte / Vesper Counter は実装済みですが、正式アニメーションや専用モデルは未実装で、プリミティブ表示と簡易VFXによる仮演出です。
- コンボは現状、表示のみで、ダメージ倍率やスコアには影響しません。
- Vesper Artは仮演出で、正式アニメーションや正式VFXは未実装です。
- Flow消費アクションとリザルト評価は仮調整です。正式な必殺技、カットイン、報酬計算はまだ未対応です。
- 死亡時や勝利時はプロトタイプ状態をリセットするだけで、タイトル画面への遷移はありません。
- 勝利/死亡表示、簡易リザルト、Result JSONコピーは検証用の仮表示です。正式な勝利演出や専用リザルト画面遷移はまだありません。
- 向きガイド表示は仮モデル期間のデバッグ用です。正式モデルが入ったら削除予定です。
- カメラ揺れと命中時VFXは仮調整です。VFXは標準ノードだけの簡易表現で、正式素材や本格的なパーティクルはまだありません。

## 旧Unity版ファイルについて
- 旧Unity版ファイルは現時点では参考資料として残す。
- Godot版の基本戦闘が安定した段階で、別ブランチまたは archive/ に移動することを検討する。
- ただし、削除・移動はユーザー確認後に行う。

## 次の実装優先順位:
1. 攻撃パターンの追加調整
2. 敵AIの追加調整
3. リザルト評価の調整 / 専用UI検討
