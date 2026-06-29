# Project Vesper 戦闘企画書 v0.2

## 1. 企画概要

**Project Vesper** は、Godot 4.7 / GDScript で開発する、2.5D見下ろし視点のスタイリッシュアクション戦闘プロトタイプである。

現時点の目標は、ローグライト化、ハクスラ化、TPS化、正式モデル実装まで一気に進めることではない。  
まずは、**強敵1体〜少数精鋭との戦闘が本当に面白いか**を検証する。

Project Vesper の戦闘は、雑魚を大量に倒す爽快アクションではなく、敵の攻撃リズムを読み、回避・パリィ・差し込み・反撃を選び、Flowを高めてスタイリッシュな一撃で締める PvE デュエルアクションである。

正式な3Dモデルやアニメーションはまだ使わず、カプセルやボックスなどの仮モデルで、まずは素早くテストプレイできることを優先する。

---

## 2. 最初に目指す戦闘体験

最初に目指すのは、以下のような戦闘体験である。

```text
敵の攻撃予兆を見て、
回避・パリィ・差し込み攻撃を選び、
敵のリズムを捌きながらFlowを高め、
反撃できる瞬間に正しく反撃し、
最後にVesper Artで締める。
```

重要なのは、**音楽に同期するリズムゲームではない**こと。

Project Vesper のリズムはBPMではなく、以下から生まれる。

```text
敵の構え
武器の引き方
攻撃予兆
間合い
連撃テンポ
攻撃後の隙
フェイント
```

目指す感触は、

```text
音楽に合わせるゲームではなく、
敵の殺意のリズムを読み、いなし、崩すゲーム。
```

である。

---

## 3. v0.2で強化する中核コンセプト

v0.1では、戦闘の核を以下のように定義していた。

```text
速い攻撃は捌く。
遅い攻撃は差し込む。
掴みは避ける。
アーマー技は空振らせる。
フェイントは待つ。
読み切ったらFlowを奪い、スタイリッシュな一撃で締める。
```

v0.2では、ここに **Rhythm Parry / Light Attack Deflect** の考え方を追加する。

### Rhythm Parry / Light Attack Deflect

弱攻撃や速い斬りは、パリィ成功時に敵の攻撃リズムを止めない。  
敵は連撃を続け、プレイヤーはそれを連続パリィで受け流す。

```text
敵の弱攻撃連撃
↓
プレイヤーがパリィでいなす
↓
敵のリズムは止まらない
↓
プレイヤーのパリィ硬直・クールダウンは即回復
↓
次の攻撃も続けてパリィできる
↓
Flowが増える
↓
反撃できる瞬間に攻撃へ移る
```

これにより、パリィは単なる「敵を止める防御」ではなくなる。

```text
弱攻撃パリィ = 敵のテンポに乗ってFlowを稼ぐ受け流し
重攻撃パリィ = 敵を止めて反撃権を得る読み勝ち
```

という役割分担にする。

---

## 4. 戦闘の基本ループ v0.2

戦闘は以下の流れで成立させる。

```text
敵が構え・予兆を出す
↓
プレイヤーが攻撃タイプを読む
↓
回避 / ジャスト回避 / パリィ / 差し込み / 距離取りを選ぶ
↓
弱攻撃ならリズムパリィで受け流す
↓
遅い攻撃なら差し込む、または正確にパリィする
↓
掴み・アーマー技なら避けて後隙を取る
↓
成功行動でFlowが増える
↓
Flowが高まったらVesper Artを狙う
↓
勝利時にリザルト評価と戦闘ログで内容を確認する
```

このループの狙いは、単なる暗記ではない。

敵の攻撃パターンを覚えることは重要だが、毎回以下の判断が残るようにする。

```text
この弱攻撃は止めずにパリィで流すか？
ここは回避して位置を取るか？
重攻撃に差し込むか？
パリィで反撃権を取るか？
Flowを温存するか？
Vesper Artで締めるか？
```

---

## 5. プレイヤー行動の役割

プレイヤーの基本行動には、それぞれ明確な役割を持たせる。

| 行動 | 役割 | 強い場面 | 弱い場面 |
|---|---|---|---|
| 回避 | 安全寄りの防御・位置取り | 掴み、大技、アーマー技、範囲外離脱 | 連続追撃、回避後の反撃不足 |
| ジャスト回避 | 中リスク中リターンの回避成功報酬 | 攻撃を紙一重で避ける | タイミング失敗、追尾攻撃 |
| Just Dodge Counter | ジャスト回避後の軽快な反撃 | 回避後にテンポを奪う | Riposteほどの高火力はない |
| パリィ | 攻撃を受け流す高リターン防御 | 武器攻撃、弱攻撃連撃、単発重攻撃 | 掴み、アーマー技、フェイント、失敗時硬直 |
| Rhythm Parry / Deflect | 弱攻撃連撃を止めずに捌く | 速い斬り、Fast Combo | 反撃権は小さい、失敗時に危険 |
| Riposte | パリィ成功後の専用反撃 | 重攻撃や止められる攻撃をパリィした後 | 弱攻撃Deflectからは乱発させない |
| Vesper Counter | Parry Stock最大時の強化反撃 | 読み切った防御成功後 | 発動機会は限定する |
| 通常攻撃 | 差し込み・小さな反撃 | 遅い攻撃、溜め、詠唱、後隙 | 速い攻撃、アーマー技 |
| 強攻撃 | 高火力パニッシュ | 大きな後隙、スタン中 | 発生前に潰される |
| Vesper Art | Flow消費の締め技 | Flowが溜まり、確定状況を作れた時 | 空振り、雑なぶっぱ |
| 待ち | フェイント対策 | 遅延、フェイント確認 | 掴み、距離詰め |

重要なのは、どれか1つを万能にしないこと。

```text
回避だけで勝てる
パリィだけで勝てる
通常攻撃連打で勝てる
Vesper Artを雑に撃てば勝てる
```

となると浅くなる。

行動ごとに「勝てる相手」と「負ける相手」を作る。

---

## 6. 敵攻撃の基本タイプ v0.2

### 1. 速い斬り / 弱攻撃

```text
発生が速い
ダメージは低〜中
差し込みは難しい
パリィ・回避で対応する
パリィ成功時、敵を止めずに受け流す
```

役割：  
プレイヤーの雑な攻撃を止める。  
また、連続パリィによってFlowを稼ぐリズム対象にもなる。

v0.2では、速い斬りを単なる「止める攻撃」ではなく、**受け流してテンポに乗る攻撃**として扱う。

### 2. Fast Combo

```text
速い斬り
↓
速い斬り
↓
速い斬り
↓
遅延重斬り、掴み、アーマー技などへ派生
```

役割：  
プレイヤーに連続パリィの気持ちよさを与えつつ、最後の派生で判断を要求する。

狙いは以下。

```text
弱攻撃3連は捌ける。
でも最後まで脳死パリィすると狩られる。
```

### 3. 遅延重斬り

```text
予兆が長い
ダメージは高い
早押しパリィを狩る
発生前に通常攻撃で差し込める
パリィ成功時は敵を止め、Riposteにつながる
```

役割：  
プレイヤーに「待つか、差し込むか、正確にパリィするか」を判断させる。

### 4. 掴み

```text
パリィ不可
ガード不可
近距離で使う
回避やバックステップで対応する
```

役割：  
パリィ偏重を咎める。

### 5. アーマー叩きつけ

```text
発生中に軽攻撃では止まらない
パリィ不可、または通常パリィでは止められない
大ダメージ
予兆はかなり分かりやすい
回避後に大きな後隙を殴れる
```

役割：  
雑な差し込みと脳死パリィを咎める。

### 6. 後退フェイント攻撃

```text
攻撃前に少し後退する
早押しパリィを誘う
短い斬りに移行する
見て待てば対応できる
```

役割：  
パリィボタンを反射で押すプレイヤーを咎める。

現行実装メモ：
`enemy_controller.gd` の `RETREAT_SLASH` は `Retreat Pressure` パターンとして組み込み済み。予兆中に少し後退し、引いた構えから短い Deflect 対応斬りへ移行する。

---

## 7. パリィ設計 v0.2

v0.2では、パリィ成功時の挙動を敵攻撃タイプごとに分ける。

| 敵攻撃タイプ | パリィ可否 | 敵を止める | 反撃権 | Flow | Parry Stock |
|---|---:|---:|---:|---:|---:|
| 速い斬り / 弱攻撃 | 可 | 止めない | 原則なし | 中 | なし、または小 |
| Fast Combo中の弱攻撃 | 可 | 止めない | 原則なし | 中〜大 | なし、または小 |
| Fast Comboの締め重攻撃 | 可 | 止める | Riposte可 | 大 | あり |
| 遅延重斬り | 可 | 止める | Riposte可 | 大 | あり |
| 後退斬り（定義のみ / 未採用） | 可 | 止めない | 原則なし | 中 | なし |
| 掴み | 不可 | なし | なし | なし | なし |
| アーマー叩きつけ | 原則不可 | なし | 回避後に反撃 | なし | なし |

### 成功時

弱攻撃パリィ成功時は、以下のようにする。

```text
ダメージ無効
敵のコンボ継続
プレイヤーのパリィ硬直を即終了
パリィクールダウンを即回復
Flow獲得
連続成功ならFlowボーナス
DEFLECT! などの表示
```

重攻撃パリィ成功時は、以下のようにする。

```text
ダメージ無効
敵を止める
敵を短時間スタン
Riposte Ready
Parry Stock増加
Flow獲得
PARRY! 表示
```

### 失敗時

パリィ失敗時は、明確な無防備時間を作る。

```text
パリィ受付に失敗
↓
短い無防備硬直
↓
その間に敵攻撃を受けると被弾しやすい
```

初期目安：

| 項目 | 初期値 |
|---|---:|
| パリィ受付 | 0.12〜0.18秒 |
| 成功時リカバリ | 0〜0.05秒 |
| 成功時クールダウン | 即回復 |
| 失敗時リカバリ | 0.35〜0.5秒 |
| 弱攻撃Deflect Flow | +8〜+12 |
| 連続Deflectボーナス | 2回目以降 +2〜+4 |
| 連続Deflect猶予 | 0.8〜1.2秒 |

失敗時に被ダメージ増加補正を重ねる必要は、初期段階ではない。  
まずは「失敗硬直で殴られる」だけで十分とする。

---

## 8. Flowシステム v0.2

Flowは、成功行動を評価し、Vesper Artへつなげる戦闘資源である。

Flowは単なる必殺ゲージではない。  
敵の攻撃を正しく処理し、戦闘の主導権を握っていることを示す。

| 行動 | Flow上昇の方向 |
|---|---:|
| 弱攻撃Deflect成功 | 中 |
| 連続Deflect成功 | 中 + 連続ボーナス |
| ジャスト回避成功 | 中 |
| Just Dodge Counter命中 | 中 |
| 重攻撃パリィ成功 | 大 |
| Riposte命中 | 大 |
| Vesper Counter命中 | 大 |
| 遅い攻撃への差し込み成功 | 中〜大 |
| Vesper Art命中 | 評価対象、Flowは消費 |
| 被弾 | 現行実装では減少なし |
| Vesper Art空振り | 消費、または減点 |

Flowの理想は以下。

```text
攻撃連打だけでは溜まりにくい。
敵の攻撃を正しく捌くと早く溜まる。
上手いプレイほどVesper Artを早く狙える。
```

つまり、Project Vesperでは、

```text
攻撃連打でDPSを出す
```

よりも、

```text
敵の攻撃をいなしてFlowを稼ぎ、
確定状況でVesper Artを当てる
```

方が、結果的に早く美しく勝てるようにする。

---

## 9. Vesper Artの役割

Vesper Artは、Flowを消費する高威力の一撃である。

役割は以下。

```text
戦闘の締め
Flowを溜めた報酬
上手いプレイの可視化
リザルト評価の加点対象
```

ただし、雑に撃てば強い技にはしない。

```text
Flowを消費する
空振りすると損をする
敵の後隙やスタン中に狙う
連発できない
```

Vesper Artは、プレイヤーが敵のリズムを読み切った後に叩き込む「句読点」のような技にする。  
文章の途中に何度も句点を打つと読みにくい。戦闘も同じ。

---

## 10. リザルト評価 / スタイルランク

勝利時には、戦闘内容を簡易リザルトとして表示する。

評価対象は以下。

```text
Clear Time
Damage Taken
Hit Taken Count
Max Combo
Parry Count
Rhythm Parry / Deflect Count
Just Dodge Count
Interrupt Count
Riposte Hit Count
Vesper Counter Hit Count
Just Dodge Counter Hit Count
Vesper Art Use Count
Vesper Art Hit Count
Final Flow
```

ランクは以下を使う。

```text
D / C / B / A / S / VESPER
```

評価方針は以下。

```text
被弾が少ない
敵の攻撃を正しく処理している
Flowを溜めている
カウンターを活用している
Vesper Artを当てている
短時間で倒している
```

リザルト評価は、プレイヤーに「何が上手いプレイなのか」を伝えるための仕組みである。

ただ勝っただけではなく、

```text
どう勝ったか
どの行動が良かったか
どこが雑だったか
```

を見えるようにする。

---

## 11. 戦闘ログ / Run Log

テストプレイ後、戦闘内容をJSONとしてコピーできるようにする。

目的は、調整と分析をしやすくすること。

ログに含める項目例：

```json
{
  "schemaVersion": 1,
  "result": "victory",
  "rank": "S",
  "score": 1280,
  "clearTime": 42.8,
  "damageTaken": 12,
  "hitTakenCount": 2,
  "maxCombo": 18,
  "finalFlow": 35,
  "parryCount": 5,
  "normalParryCount": 2,
  "rhythmParryCount": 7,
  "deflectCount": 7,
  "maxDeflectChain": 3,
  "parryFailCount": 1,
  "justDodgeCount": 4,
  "interruptCount": 2,
  "riposteHitCount": 3,
  "vesperCounterHitCount": 1,
  "justDodgeCounterHitCount": 2,
  "vesperArtUseCount": 1,
  "vesperArtHitCount": 1,
  "vesperArtMissCount": 0
}
```

ログがあることで、感覚だけでなく数字を見ながら調整できる。

```text
Flowが溜まりすぎていないか
パリィが強すぎないか
Vesper Artを撃てる回数が多すぎないか
被弾してもランクが高すぎないか
敵の連撃が機能しているか
```

を確認する。

---

## 12. PvE向け読み合い設計

Project Vesperでは、格ゲー的な読み合いを取り入れるが、見えない二択は避ける。

原則は以下。

```text
見えない二択ではなく、見える選択肢。
ただし、見えてから最適行動を選ぶには少し練習がいる。
```

敵の攻撃には、必ず見分けられる予兆を用意する。

| 敵の予兆 | 意味 | 推奨対応 |
|---|---|---|
| 武器を小さく引く | 速い斬り | Deflect、回避 |
| 速い斬りが連続する | Fast Combo | Rhythm Parryで捌き、締めを読む |
| 武器を大きく後ろに引く | 遅延重攻撃 | 差し込み、距離取り、正確なパリィ |
| 片手を前に出す | 掴み | 回避、バックステップ |
| 体が赤く光る | アーマー技 | 殴らず回避、後隙を取る |
| 構えたまま止まる | フェイント気味 | 早押しせず待つ |

プレイヤーが負けたときに、

```text
今のは見えていたのに焦った
弱攻撃連撃のリズムを外した
パリィに頼りすぎて掴まれた
差し込める技だったのに逃げた
アーマー技に殴りかかってしまった
Vesper Artを雑に撃った
```

と思えることが理想である。

```text
ランダムで死んだ
CPUがズルした
見えなかった
何をすれば良かったか分からない
```

と思わせてはいけない。

---

## 13. アクションのスピード感

Project Vesperでは、攻撃フレームを全体的に長めにする。

目指すのは、

```text
素早いけど軽くない。
派手だけど雑ではない。
見て判断できるが、完璧に捌くには練習がいる。
```

というスピード感である。

目安は以下。

| 技タイプ | 予兆時間の目安 | 目的 |
|---|---:|---|
| 速い斬り | 0.35〜0.5秒 | 緊張感を出すが、理不尽にはしない |
| Fast Combo中の連撃間隔 | 0.25〜0.45秒 | Rhythm Parryのテンポを作る |
| 通常攻撃 | 0.5〜0.8秒 | 見て防御行動を選べる |
| 遅延重攻撃 | 0.9〜1.3秒 | 差し込み判断を促す |
| 掴み | 0.6〜0.9秒 | パリィ不可を見て避ける |
| アーマー技 / 大技 | 1.2〜2.0秒 | 位置取り、回避後反撃、特殊反撃のチャンス |

速すぎるゲームにはしない。  
ただし、弱攻撃連撃だけはテンポを少し速め、プレイヤーがリズムで受け流す場面を作る。

---

## 14. 成功時の気持ちよさ

Project Vesperでは、成功時の手応えを非常に重視する。

成功時には、以下を段階的に追加する。

```text
ヒットストップ
短いスロー
カメラ揺れ
カメラ寄り
効果音
簡易VFX
敵の怯み
Flow表示
スタイリッシュカウンター演出
```

v0.2では、成功演出に強弱を付ける。

| 成功行動 | 演出の強さ |
|---|---|
| 通常ヒット | 小 |
| 弱攻撃Deflect | 小〜中、テンポ重視 |
| 連続Deflect | 中、リズム感重視 |
| ジャスト回避 | 中 |
| Just Dodge Counter | 中 |
| Interrupt | 中〜大 |
| 重攻撃パリィ | 大 |
| Riposte | 大 |
| Vesper Counter | 大〜特大 |
| Vesper Art | 特大 |

弱攻撃Deflectは、演出を重くしすぎない。  
毎回強いヒットストップを入れると、敵の連撃テンポが死ぬためである。

---

## 15. 当面やらないこと

初期段階では、以下はやらない。

```text
音楽BPMとの同期
見えない二択
大量の雑魚を倒すハクスラ戦闘
ランダムステージ生成
装備ドロップ
永続成長
複数キャラ実装
正式3Dモデル前提の処理
正式リザルト画面遷移
タイトル画面やメニュー画面
大規模な状態管理フレームワーク
過剰な抽象化
```

今は戦闘の芯を焼く段階である。  
ソースを増やす前に、肉の火入れを見なさい。

---

## 16. 現在の実装段階

現在のProject Vesperでは、以下の要素が実装済み、または実装対象になっている。

```text
プレイヤー攻撃の状態管理
敵攻撃の予兆表示
ヒットストップ
カメラ揺れ
簡易VFX
パリィ
ジャスト回避
Flow表示
コンボ表示
Riposte
Vesper Counter
Vesper Art
距離別敵AI
対パリィ補正
対アグレッション補正
Flow消費アクション
Just Dodge Counter
リザルト評価 / スタイルランク
戦闘ログ / Result JSONコピー
Rhythm Parry / Light Attack Deflect Phase 1
```

次に強化するべき核は、

```text
Fast Combo / Deflectテンポ調整
Flow / Vesper Artバランス再調整
リザルト評価の精度向上
```

である。

---

## 17. 次の実装優先順位 v0.2

### Step 1: Rhythm Parry / Light Attack Deflect Phase 1 - implemented

目的：  
弱攻撃パリィ成功時に敵を止めず、敵の連撃リズムを維持したままFlowを稼げるようにする。

実装内容の方向：

```text
敵攻撃タイプに parry_stops_enemy のような設定を追加
速い斬りは parry_stops_enemy = false
重攻撃や締め攻撃は parry_stops_enemy = true
弱攻撃Deflect成功時はプレイヤーのパリィ硬直・クールダウンを即回復
弱攻撃Deflect成功時は敵コンボを継続
弱攻撃Deflect成功時はFlow獲得
連続DeflectでFlowボーナス
パリィ失敗時は無防備硬直を明確化
弱攻撃DeflectだけではRiposteを乱発できないようにする
UIに DEFLECT! / DEFLECT xN を表示
戦闘ログに rhythmParryCount / deflectCount / maxDeflectChain / parryFailCount を追加
```

### Step 2：Fast Comboの調整

目的：  
Rhythm Parryが気持ちよく機能するよう、速い斬り連撃のテンポを調整する。

確認点：

```text
連撃間隔が速すぎないか
パリィ成功時の硬直がテンポを壊していないか
最後の重攻撃・掴み・アーマー派生が見えるか
Flowが溜まりすぎないか
```

### Step 3：Flow / Vesper Art バランス再調整

目的：  
Rhythm Parry追加後、Flowが溜まりすぎないか確認する。

調整方針：

```text
攻撃連打より、上手い防御成功の方がFlow効率が良い
ただし、弱攻撃DeflectだけでVesper Artを連発できない
1戦で1〜2回程度、上手ければ狙える
```

### Step 4：リザルト評価更新

目的：  
Rhythm Parryを評価項目に追加する。

追加項目：

```text
Normal Parry Count
Rhythm Parry Count
Deflect Count
Max Deflect Chain
Parry Fail Count
```

### Step 5：敵攻撃パターン追加

Rhythm Parryが安定してから、以下を追加検討する。

```text
突進攻撃
扇形範囲攻撃
距離詰め攻撃
連撃からの掴み派生
ディレイ付き二段攻撃
```

敵パターン追加は、Rhythm Parryの手触り確認後に行う。

---

## 18. Codex向け実装ルール

Codexに実装させる場合、以下を守らせる。

```text
- Godot 4.7 / GDScript を前提にする
- 既存の Node / Scene 構成を尊重する
- Unity版の逐語移植はしない
- gameplay scripts は責務ごとに小さく分ける
- 調整値は可能な限り @export 変数にする
- 正式モデルや正式アニメーション前提にしない
- プリミティブ表示、色変更、簡易VFXでよい
- まずテストプレイしやすさを優先する
- 大規模なイベントバスや過剰な抽象化は入れない
- 旧Unity版ファイルは明示指示なしに編集・削除しない
- 戦闘バランスを変える実装では、README / DEV_GUIDELINES / 企画書との整合を確認する
- 新機能を足す前に、既存の戦闘ループを壊していないか確認する
```

---

## 19. この企画の一文要約 v0.2

Project Vesperは、

```text
敵の攻撃リズムを読み、弱攻撃は受け流し、重攻撃は崩し、掴みやアーマー技は避け、Flowを高めてVesper Artで締める、PvE向け2.5Dデュエルアクション。
```

である。

もっと短く言えば、

```text
敵の殺意のリズムをいなし、美しく主導権を奪うゲーム。
```

である。

まずはここをブレさせない。  
ローグライト化、ハクスラ化、TPS化は後で考える。今は戦闘の芯を焼く段階である。

## Enemy Motion Readability / Telegraph Debug Toggle Phase 1

Project Vesper is moving enemy attack recognition away from floor color dependency and toward enemy motion readability: body lean, arm position, weapon pull, weapon visibility, and stance silhouette.

Floor telegraphs remain available as debug/assist visuals with three modes: `FULL_DEBUG`, `MINIMAL`, and `OFF`. `FULL_DEBUG` keeps the old clear floor-color language, `MINIMAL` uses a neutral helper for range/active-area testing, and `OFF` hides floor telegraphs for pure enemy-pose readability checks.

Fast Combo / Deflect tempo is intentionally preserved in this phase. Fast/light attacks still use Deflect behavior, delayed heavy still uses normal Parry behavior, and grab / armor slam remain non-parry-success cases.

## Fast Combo Finisher Branch / Existing Combo Role Cleanup Phase 1

- Fast Combo now preserves the existing first three fast/light Deflect beats, then branches into a delayed heavy, grab, or armor slam finisher.
- The delayed heavy finisher remains the basic readable route into precise Parry, interrupt timing, Riposte Ready, and Parry Stock interaction.
- Grab and armor slam finishers remain non-parry-success cases so blind repeated Parry/Deflect can be punished.
- Existing combo family roles stay separate: Fast Combo = Rhythm Parry / Deflect showcase into finisher read; Simple Pressure = short pressure; Grab Mix = early parry-habit punishment; slam patterns = anti-mash / anti-blind-parry punishment.
- Flow / Vesper Art balance and result rank scoring are not the target of this phase.
## Fast Combo Finisher Weight Tuning Phase 1

- Fast Combo finisher weights now make delayed heavy the primary ending, with grab and armor slam as occasional punish options.
- The current default finisher ratio is `82 / 13 / 5` for delayed heavy / grab / armor slam.
- Existing Grab Mix, Pressure into Slam, and Slash Slam Mix patterns remain in the enemy kit, with Slam-heavy routes reduced and still tunable through exported weights.
- Dangerous Grab/Slam outcomes are remembered lightly so repeated dangerous outcomes are suppressed; Slam outcomes also briefly suppress all Slam sources, and the next Fast Combo after a dangerous outcome prefers Heavy Finish.
- Fast Combo Deflect rhythm, Flow gain, Vesper Art balance, and parry/deflect success behavior are intentionally unchanged.
