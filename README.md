-- ==========================================
-- みそらHUB✦ RAINBOW
-- ==========================================
local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"))()
end)

if not success or not OrionLib then
    warn("OrionLibのロードに失敗しました。")
    return
end

OrionLib.Folder = "MackHubConfig"

if OrionLib.Themes then
    OrionLib.Themes.Default = {
        Main = Color3.fromRGB(25, 22, 15),
        Second = Color3.fromRGB(35, 30, 20),
        Stroke = Color3.fromRGB(212, 175, 55),
        Divider = Color3.fromRGB(160, 130, 40),
        Text = Color3.fromRGB(255, 245, 220),
        TextDark = Color3.fromRGB(180, 160, 110),
        Tab = Color3.fromRGB(45, 38, 25),
        TabSelected = Color3.fromRGB(212, 175, 55),
        Element = Color3.fromRGB(35, 30, 20),
        ElementBorder = Color3.fromRGB(180, 145, 45)
    }
end

local Window = OrionLib:MakeWindow({
    Name = "みそらHUB ✦ RAINBOW",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "MackHubConfig",
    Color = Color3.fromRGB(212, 175, 55)
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- 各BOTの有効状態フラグ
local autoRonpaEnabled = false
local isSendingRonpa = false

local autoHisuEnabled = false
local isSendingHisu = false

local isLaughEnabled = false
local squadChance = 0.1
local laughToggleWidget = nil
local lastChatTime = os.clock()

local autoHiroyukiEnabled = false
local isSendingHiroyuki = false

local autoHikakinEnabled = false
local isSendingHikakin = false

local autoHoriEnabled = false
local isSendingHori = false

local autoOjisanEnabled = false
local isSendingOjisan = false
local autoChuunibyouEnabled = false
local isSendingChuunibyou = false

local autoStrongReplyEnabled = false
local isSendingStrongReply = false

local autoOppositeEnabled = false
local isSendingOpposite = false

local autoNekketsuEnabled = false
local isSendingNekketsu = false

local autoLyricEnabled = false
local isSendingLyric = false

local autoLaughReactEnabled = false
local isSendingLaughReact = false

local autoSharpEnabled = false
local isSendingSharp = false

local autoYudanEnabled = false
local isSendingYudan = false

local autoHoriReligionEnabled = false
local isSendingHoriReligion = false

-- 対BOT（連投検知 + BOTワード検知）
local autoAntiBotEnabled = false
local isSendingAntiBot = false
local antiBotThreshold = 3
local antiBotTimeWindow = 1
local antiBotCooldown = 1
local playerChatHistory = {}
local playerLastAntiBot = {}

-- ぶりっ子
local autoBurikkoEnabled = false
local isSendingBurikko = false

-- 自分宛て
local autoMentionEnabled = false
local isSendingMention = false
local mentionSelected = "呼んだ?"

-- 67BOT
local auto67Enabled = false
local isSending67 = false

local existingPlayers = {}
for _, player in ipairs(Players:GetPlayers()) do
    existingPlayers[player.UserId] = true
end

local function showNotification(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3,
        })
    end)
end

-- ==========================================
-- 文字カウント用ヘルパー（マルチバイト対応）
-- ==========================================
local function CountPlain(text, char)
    local count = 0
    local pos = 1
    local len = #char
    while true do
        local s = text:find(char, pos, true)
        if not s then break end
        count = count + 1
        pos = s + len
    end
    return count
end

local function HasConsecutiveW(text)
    local t = text:gsub("ｗ", "w"):gsub("Ｗ", "W")
    for run in t:gmatch("[wW]+") do
        if #run >= 2 then return true end
    end
    return false
end

-- ==========================================
-- 送信キュー（チャット規制対策）
-- ==========================================
local chatQueue = {}
local isProcessingQueue = false
local lastSendTime = 0
local SEND_INTERVAL = 2.5

local function SendChatMessage(text)
    table.insert(chatQueue, text)
    if isProcessingQueue then return end

    task.spawn(function()
        isProcessingQueue = true
        while #chatQueue > 0 do
            local now = os.clock()
            local elapsed = now - lastSendTime
            if elapsed < SEND_INTERVAL then
                task.wait(SEND_INTERVAL - elapsed)
            end

            local msg = table.remove(chatQueue, 1)

            pcall(function()
                if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                    local textChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                    if textChannel then
                        textChannel:SendAsync(msg)
                    end
                else
                    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                    if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
                        chatEvents.SayMessageRequest:FireServer(msg, "All")
                    end
                end
            end)

            lastSendTime = os.clock()
        end
        isProcessingQueue = false
    end)
end

-- ==========================================
-- UI レインボー化タスク
-- ==========================================
task.spawn(function()
    local hue = 0
    while true do
        hue = (hue + 0.005) % 1
        local rainbowColor = Color3.fromHSV(hue, 0.8, 1)

        pcall(function()
            OrionLib.Color = rainbowColor
            local orionGui = CoreGui:FindFirstChild("Orion") or LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("Orion")
            if orionGui then
                for _, v in ipairs(orionGui:GetDescendants()) do
                    if v:IsA("UIStroke") then
                        v.Color = rainbowColor
                    elseif v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("TextLabel") then
                        if v.Name == "Selected" or v.Name == "Slider" or v.Name == "Toggle" or v.Name == "Icon" then
                            if v:IsA("TextLabel") then
                                v.TextColor3 = rainbowColor
                            else
                                v.BackgroundColor3 = rainbowColor
                            end
                        end
                    end
                end
            end
        end)
        RunService.RenderStepped:Wait()
    end
end)

-- ==========================================
-- 各BOTのセリフプール
-- ==========================================

-- 1. 論破BOTメッセージ
local ronpaMessages = {
    "はい論破ぁぁぁぁwボキの勝ちぃぃぃぃぃぃいぃ",
    "君のその意見、論理的破綻してて草なんだが?w",
    "データも根拠もない主観だけで語るのやめてもろていいですか?w",
    "論破完了。お疲れ様でしたーw",
    "小学生でも思いつく反論すらできなくて草w",
    "はい論破!次の方どうぞーw",
    "君の負けね。はい論破完了っとw",
    "語れば語るほどボロが出るの天才的だねw論破w",
    "論理の飛躍がすごすぎて宇宙まで飛んでいきそうw論破w",
    "はい、今の発言で完全論破されましたーw",
    "反論の余地すら与えずに論破するの気持ちよすぎる",
    "お前のその理論、豆腐より脆くて草w論破!",
    "論破されたショックで画面見れなくなってて草w",
    "はい、一撃で論破完了。秒速で終わって草",
    "論破の教科書に載せたいレベルの美しい負け方だねw",
    "その場しのぎの嘘を並べても論破されるだけだぞw",
    "論理的思考力ゼロなのに議論に参加するのなんで?w論破!",
    "はい論破!君の反論、全部こっちで論理的に粉砕したからw",
    "論破されて顔真っ赤になってるの画面越しに伝わってくるよw",
    "議論の土俵にも立ててないんだよなぁ…はい論破w",
    "お前のその発言、丸ごと論破してリセットしてあげようか?w",
    "論破マシーン みそら様の前に沈みなさいwはい論破!",
    "言葉の意味も分からずに使ってるからそうやって論破されるんだよw",
    "はい論破!これ以上言い訳してもみっともないだけだぞw",
    "論破されるために生まれてきたようなピエロだなw",
    "論理の通らないオモチャみたいな意見、綺麗に論破してやったぜw",
    "はい論破!次の標的を探すとするかw",
    "君のその浅はかな知恵、みそら様の手にかかれば一瞬で論破よw",
    "論破された後の沈黙、嫌いじゃないぜw",
    "はい論破!お前の敗北が今日のハイライトだわw",
    "議論で勝てないからって発狂するのやめなよwはい論破!",
    "論理のパズルが全部間違ってるんだよなぁ…はい論破w",
    "はい論破!お前の全否定完了のお知らせですw",
    "論破されたくなかったら、もう少しマシなセリフ用意してきなw",
    "はい論破!今日も平和に格下の相手を料理できましたw",
    "論破の快感に酔いしれる時間だぁ!はい論破!",
    "お前のその薄い理論、風が吹くだけで崩壊するぞw論破w",
    "はい論破!お前の敗北確定演出入りましたーw",
    "論理的思考の欠片もないその回答、見事に論破してやったぜw",
    "はい論破!これでお前も黙るしかなさそうだなw",
    "論破された事実を受け止めて、出直してきなさいw",
    "はい論破!お前の発言、全部綺麗にロジハラで返り討ちねw",
    "議論でマウント取ろうとして逆に論破されるのどんな気分?w",
    "はい論破!もうこれ以上言い返す言葉残ってないでしょ?w",
    "論理の刃で一刀両断!はい論破完了ですw",
    "はい論破!お前の人生そのものが論理破綻してて草",
    "論破される名人芸、今日も絶好調ですねw",
    "はい論破!これ以上恥の上塗りするのやめとけってw",
    "論理的な正論でボコボコにするの楽しすぎwはい論破!",
    "はい論破!みそら様式ロジカルパワーで完全勝利ですw"
}

-- 2. ヒス構文BOTメッセージ
local hisuMessages = {
    "え?そうやって人をおもちゃにして楽しい?人が傷つくのを見て喜ぶなんて本当に恐ろしいね",
    "ねえ、なんでそんな酷いこと言うの?私何か悪いことした?答えてよ",
    "もうやめて!これ以上私を追い詰めて何が楽しいわけ?最低だね",
    "人の気持ちを少しは考えたことあるの?本当につらい、無理",
    "どうせ私なんて何を言ってもバカにされるんだよね、知ってるよ…",
    "そんな言い方しなくたっていいじゃん!酷すぎる、許さないから",
    "私のこと笑いたいだけなんでしょ?性格悪すぎて鳥肌立つわ",
    "もう限界……これ以上耐えられないんだけど、どう責任とってくれるの?",
    "何なのその態度!人をバカにするのも大概にしてよね!",
    "私を精神的に追い詰めて楽しい?人間のクズじゃん、最悪",
    "ねえ聞いてるの!?無視しないでよ!卑怯だよ、それ!",
    "そんな冷たい言葉を平気で吐ける神経がマジで理解できない",
    "涙出てきた……どうしてこんな酷いこと言う人に囲まれてるの私",
    "謝ってよ!今すぐ謝って!じゃないと許さないからね!",
    "私のことサンドバッグとしか思ってないでしょ?最低の人間だね",
    "もう二度と話しかけないで!本当に不愉快だし気持ち悪い",
    "なんで私ばかりこんな目に遭わなきゃいけないの?理不尽すぎ!",
    "お前らのその冷笑的な態度、マジで反吐が出るんだけど",
    "人の心とかないんか?お前らのせいで全部台無しだよ",
    "もういい!勝手に言ってろ!二度と私の視界に入らないで!",
    "そんなこと言うために生まれてきたの?親の顔が見てみたいわ",
    "私を傷つけて何が残るの?空虚な人生送ってて楽しい?",
    "うわ、最悪。今すぐこの場から消え失せてほしいんだけど",
    "私の純粋な気持ちを踏みにじってさ、楽しいかい?あぁ?",
    "もう我慢の限界だからね!これ以上やったらどうなるか分かってる?",
    "何が面白いの?その乾いた笑い声、耳障りで仕方ないんだけど",
    "被害者ぶってるって言いたいわけ?お前らのせいでこうなったんだよ!",
    "マジで頭おかしいんじゃないの?病院行ってきなよ、本気で",
    "私の存在がそんなに邪魔?なら最初から関わらないでよ!",
    "こんな暴言吐かれて平気でいられるとか、神経疑うわ",
    "もう二度と信じない。全員敵に回す覚悟でやってるんだよね?",
    "お前のその汚い言葉、全部スクリーンショット保存したからな",
    "何様的態度なの?ただのネットいじめじゃん、通報するから",
    "私のことバカにしてスッキリした?小物すぎて哀れだね",
    "もう疲れた……なんで私だけこんな目に遭わなきゃいけないわけ?",
    "お前らのせいで私の人生狂ったんだけど、どうしてくれるの?",
    "ふざけるなよ!人の気持ちをなんだと思ってんだよ!",
    "もう許さないから。徹底的にやってやるから覚悟しといて",
    "こんなクソみたいなサーバー、もう二度と入ってやるもんか!",
    "私の善意をあだで返すような真似して、恥ずかしくないの?",
    "ねえ、自分の言ってることの異常さに気づいている?怖すぎる",
    "これ以上私を怒らせないほうがいいよ?本当に面倒くさいから",
    "どうせ陰で私のこと笑ってるんでしょ?知ってるよ、全部",
    "人間の屑が集まって何が楽しいの?お前ら全員大嫌い",
    "私の邪魔をしないでって言ってるの!聞こえてないわけ?",
    "もう嫌だ!こんな世界今すぐ滅びればいいのに!",
    "お前らのその薄ら笑い、いつか絶対バチが当たるからな",
    "私をそこまで追い詰めて、何かいいことあるわけ?最悪だわ",
    "もう言葉が出ない……ここまで腐った人間初めて見た",
    "私のことこれ以上怒らせたら、どうなるか思い知らせてやる!"
}

-- 3. ひろゆき構文BOTメッセージ
local hiroyukiMessages = {
    "それってあなたの感想ですよね?何かそういうデータとかあるんですか?w",
    "え、なんか嘘つきって言われるのって、なんかそういうデータあるんですか?w",
    "論破されちゃいました?w なんかそれ、負け惜しみっぽくないですか?w",
    "うーん、それって何の意味があるんですか?時間の無駄じゃないですか?w",
    "ボクの周りではそんなこと言う人いないですけど、狭いコミュニティなんですかね?w",
    "データに基づいて話してもらっていいですか?主観で語られても困るんですけどw",
    "それって、あなたの脳内妄想のデータに基づいている感じですか?w",
    "なんか、すぐ感情的になっちゃう人って、論理的思考が苦手なんですかね?w",
    "え、今の発言、なんか根拠とかあるんですか?それとも適当に言ってるだけ?w",
    "それ、何か社会的信用があるデータとか出せます?出せないならただの感想ですよねw",
    "うわ、なんか必死に反論してて草なんですけど、何かデータあるんですか?w",
    "論理的な反論ができないからって、すぐ人格攻撃に走るのってどうなんですかねw",
    "それって、あなたの感想ですよね?(二回目)w",
    "なんか、自分の意見が正しいと思い込んでる人って幸せそうでいいですよねw",
    "データを出せないなら、その話はもう終了でいいんじゃないですか?w",
    "え,なんか都合が悪くなると黙っちゃうの、特技なんですか?w",
    "それ、客観的事実じゃなくて主観ですよね?何か客観データあります?w",
    "うーん、コスパ悪い議論してる自覚とかってあります?w",
    "なんか、マウント取ろうとして逆に滑ってるのめちゃくちゃ面白いですねw",
    "それって、あなたの感想以外の何物でもないですよね?w",
    "論破されるのが怖いからって、逃げ出すの早くないですか?w",
    "なんか、知ったかぶりして恥ずかしくないんですかね?w",
    "それ、何か信用できるソースとかあるんですか?ネットの噂レベルですか?w",
    "え、なんか怒っちゃいました?図星突かれてイライラするの可愛いですねw",
    "データなき議論に付き合うほど暇じゃないんですよね、ボクw",
    "それ、あなたの主観的な感想をさも事実のように語ってるだけですよね?w",
    "うーん、頭の悪い人特有の論理展開で見ていて微笑ましいですw",
    "なんか、形勢不利になった途端に捨て台詞吐くのって定石なんですか?w",
    "それ、何か具体的な数字とか出せます?出せないならノーカンでw",
    "え、自分の発言の矛盾点に自分で気づいてない感じですか?w",
    "それってあなたの感想ですよね?分かって言ってます?w",
    "なんか、論理でボコボコにされて泣きそうになってません?w",
    "データなしの精神論とか、昭和の価値観すぎてお腹痛いんですけどw",
    "うーん、それ、小学生の屁理屈と変わらなくないですか?w",
    "なんか、一生懸命文字打ってるとこ申し訳ないんですけど、意味ないですよw",
    "それ、あなたの感想ですよね?それ以外の言葉って知らないんですか?w",
    "客観的なデータも出せずに吠えてる姿、見世物として最高ですねw",
    "え、なんか自分の負けを認められないのって、プライド高いだけですか?w",
    "それ、論理破綻してるって指摘されるの人生で何回目ですか?w",
    "うーん、コスパ最悪のレスバトルごっこ、お疲れ様ですw",
    "それってあなたの感想ですよね?(三回目)もうその話飽きましたよw",
    "なんか、相手を論破したときの快感って麻薬みたいですよねw",
    "データのない議論はただの雑談、いや、ただの愚痴ですよw",
    "え、なんか必死に連投してて草なんですけど、何かデータあるんですか?w",
    "それ、あなたの感想ですよね?って言われたらなんて言い返すんですか?w",
    "うーん、論理的思考力をどこかに置いてきちゃった系の人ですかね?w",
    "なんか、自分の無知を棚に上げて怒るのって特技なんですか?w",
    "それ、何か公的なデータとかに基づいています?まさか妄想じゃないですよねw",
    "え、論理で返り討ちにされてフリーズするの早すぎませんか?w",
    "それってあなたの感想ですよね?……はい、今日も完全勝利っとw"
}

-- 4. HIKAKIN冷笑BOTメッセージ
local hikakinMessages = {
    "どうも、HIKAKINです(低音冷笑)w",
    "いやぁ、今日の動画のコメント欄も冷え切ってますねぇ(冷笑)w",
    "皆さん、こんにちは。HIKAKINで……すけど、何か?(冷たい視線)w",
    "私のチャンネルではこういう寒いコメントは削除対象なんですよねぇ(冷笑)w",
    "ブンブンハローYouTube!……と、お前のその発言、全くブンブンしてないよ(冷笑)w",
    "ヒカキンTVへようこそ。今日は、哀れな素人の滑り芸を観察します(冷笑)w",
    "1000万円企画より、お前のその滑り芸のほうがよっぽど見応えあるね(冷笑)w",
    "セイキンに見せたらなんて言うだろうね、この見事な滑りっぷり(冷笑)w",
    "私の大親友の猫も、お前のコメント見て呆れてるよ(冷笑)w",
    "YouTubeの頂点から見下ろす景色は、お前らの滑り芸がよく見えて最高だね(冷笑)w",
    "HIKAKINボイスで冷笑される気分はどうですか?(冷笑)w",
    "チャンネル登録者数何万人いても、お前のその寒さは直せないね(冷笑)w",
    "マルチの帝王HIKAKINが、お前のその薄っぺらい発言を全否定してあげる(冷笑)w",
    "億万長者の余裕ってやつだよ、お前の必死な足掻きを冷ややかに見るのはさ(冷笑)w",
    "おっと、HIKAKIN特製の冷笑アイスクリーム、味見してみる?(冷笑)w",
    "私の動画の低評価数より、お前の人生の低評価数のほうが多そうで草(冷笑)w",
    "ブンブン……じゃなくて、冷え冷えハローYouTubeだな、ここは(冷笑)w",
    "天下のHIKAKIN様に冷笑される栄誉、噛み締めるといいよ(冷笑)w",
    "お前のそのお笑いセンス、HIKAKINブランドに泥を塗るレベルだね(冷笑)w",
    "大物ユーチューバーの冷ややかな視線、背中に突き刺さってない?(冷笑)w",
    "私のマネージャーも苦笑いしてたよ、お前のそのコメント(冷笑)w",
    "HIKAKINゲームズでも、お前みたいな雑魚キャラは即効でBAN対象だよ(冷笑)w",
    "スーパーキャットのミルクでも飲んで、頭冷やしてきなよ(冷笑)w",
    "YouTubeドリームの対極にいるお前の存在、ある意味貴重だね(冷笑)w",
    "HIKAKINの冷笑モード、発動したら誰も止められないんだよね(冷笑)w",
    "お前のその必死なレスバトル、HIKAKINのプレミアムな視界には届きません(冷笑)w",
    "日本トップのユーチューバーからの、愛ある冷笑を受け取りなさい(冷笑)w",
    "コラボ依頼お断り!お前のその寒さは感染力が強すぎるからね(冷笑)w",
    "HIKAKINの億稼ぐ頭脳から見たら、お前の思考回路はミジンコ以下だよ(冷笑)w",
    "今日も元気にヒカキンボックスから冷笑を取り出していくスタイル(冷笑)w",
    "お前のその滑り芸、HIKAKINのショート動画で晒してあげようか?(冷笑)w",
    "トップオブトップの冷笑、心ゆくまで味わうといいよ(冷笑)w",
    "私の動画に出演する権利、お前には100年早いんだよね(冷笑)w",
    "HIKAKINの冷ややかな眼差し、スクリーン越しに届いてる?(冷笑)w",
    "お前のその薄っぺらいプライド、HIKAKINのゴールドプレイボタンで削ぎ落とす(冷笑)w",
    "YouTubeの歴史上、これほど綺麗に滑る人間を私は他に知らない(冷笑)w",
    "HIKAKINの冷笑フィルターを通すと、お前の発言がすべてギャグに見える(冷笑)w",
    "日本中が注目する中、盛大に滑り散らかす才能だけは天才的だね(冷笑)w",
    "HIKAKINのファンクラブ会員の前で、お前のそのコメント披露していい?(冷笑)w",
    "億り人の余裕の笑み、これがHIKAKINクオリティの冷笑だよ(冷笑)w",
    "お前のそのピエロっぷり、HIKAKINのチャンネルの新しい企画にどう?(冷笑)w",
    "世界のHIKAKIN様が、わざわざお前を冷笑してあげてるんだから感謝しな(冷笑)w",
    "YouTubeドリームを夢見るだけの雑魚、今日も元気に冷笑されてるね(冷笑)w",
    "HIKAKINの冷笑パワー、お前の寒い心を完全に凍結させてあげる(冷笑)w",
    "お前のその必死な長文、HIKAKINの自動翻訳でも理解不能だってさ(冷笑)w",
    "トップクリエイターからの冷ややかなお言葉、胸に刻んでおきな(冷笑)w",
    "HIKAKINの足元にも及ばない底辺の叫び、心地いいBGMだね(冷笑)w",
    "お前のそのお寒い人生、HIKAKINチャンネルでモザイク処理しとくね(冷笑)w",
    "天下のHIKAKINによる、世界一贅沢な冷笑タイム終了のお知らせ(冷笑)w",
    "どうも、HIKAKINでした。お前の敗北、永遠に忘れないからね(冷笑)w"
}

-- 5. 堀大輔煽りBOTメッセージ
local horiMessages = {
    "言葉の定義すら曖昧なまま発言するから、あなたの主張はすべて破綻するんです。",
    "前提条件が間違っているのに、その上に議論を築こうとするのはナンセンスです。",
    "抽象的な概念を具体的に言語化できない時点で、あなたの思考は停止しています。",
    "論理の構造を理解せずに感情論だけで話すのは、教育を受けていない証拠です。",
    "言葉の本質を捉えられていないから、あなたの発言はすべて薄っぺらくなるんです。",
    "客観的な事実と主観的な感想の区別もつかないのですか?呆れますね。",
    "思考の解像度が低すぎるために、現実の本質が見えていない典型例ですね。",
    "定義の共有ができていない議論は、ただの時間の無駄、生産性の欠片もない。",
    "あなたのその発言、学問的にも論理的にも完全に間違っていますよ。",
    "言葉の意味を辞書で引き直してから出直してきなさい。話はそれからです。",
    "自分の無知を棚に上げて持論を展開するその厚顔無恥さ、ある意味感心します。",
    "論理的帰結を予測できない知性の低さが、すべての敗因につながっています。",
    "表面的現象にとらわれて本質を見誤る、典型的な知的怠惰の形ですね。",
    "あなたのその発言のどこに論理的妥当性があるのか、論理的に説明できますか?",
    "概念の切り分けができていないから、頭の中がぐちゃぐちゃなんですよ。",
    "正解のない問題について語る前に、まず基礎的な論理思考を学びなさい。",
    "他人の意見を模倣しているだけで、自分で考える頭を持っていないのが丸わかりです。",
    "言語化能力の欠如が、そのままあなたの人生の質の低さを表していますね。",
    "論理的破綻を指摘されて顔を真っ赤にする前に、自分の頭で考えることを覚えなさい。",
    "客観的データに基づく批判と、個人的な悪口の区別もつかないのですか?",
    "あなたのその稚拙な論理構成では、誰一人として納得させられませんよ。",
    "思考の浅さが全ての言動に滲み出ていることに、いつになったら気づくんですか?",
    "言葉を武器にするなら、最低限の知性と論理の武装をしてきなさい。",
    "前提の崩れた議論を延々と続けるその姿、滑稽としか言いようがありません。",
    "学問的背景のない持論を振りかざすのは、ただの恥さらしですよ。",
    "論理の飛躍があまりにも大きすぎて、議論の土俵にも上がれていません。",
    "自分の思考の歪みに気づけないまま歳を重ねてしまった悲しい末路ですね。",
    "言葉の定義を曖昧にして煙に巻くその手法、非常に卑劣で知性を感じません。",
    "あなたのその発言、知的レベルの低さを世界中に発信しているようなものですよ。",
    "論理の整合性が一箇所も取れていない破綻した文章、よく平気で投稿できますね。",
    "知識のインプット量が圧倒的に足りないから、そんな陳腐な意見しか出ないんです。",
    "思考の枠組み自体が歪んでいるため、正しい結論にたどり着けるはずがありません。",
    "自分の意見に対する批判的検証を怠った結果が、その哀れな主張ですね。",
    "言葉を正確に運用する能力がないのに、議論に参加しようとするのが間違いです。",
    "論理の矛盾を指摘されて沈黙するくらいなら、最初から発言しなければいいのに。",
    "あなたのその安易な二元論、知的生産性の世界では全く通用しませんよ。",
    "抽象と具体の往復ができない頭の構造をしていると、一生そのままで終わります。",
    "論理的思考のトレーニングを一度でも受けたことがあるのか疑わしいですね。",
    "他人の褌で相撲を取るような薄っぺらい理論展開、見ていて痛々しいです。",
    "自分の無知を自覚できない状態を、世間では救いようがないと言うんです。",
    "言葉の裏にある構造を読み解く力がないから、いつも表面で踊らされるんです。",
    "あなたのその幼稚な反論、論理のメスを入れるまでもなく自然崩壊していますよ。",
    "知性の欠片もない感情的な反発は、議論の場において最も不要なノイズです。",
    "論理的思考の基本である因果関係の把握すらできていない致命的な欠陥ですね。",
    "自分の頭で汗をかいて考えたことのない人間の言葉には、何の重みもありません。",
    "概念の定義を怠る怠け癖が、あなたの全ての主張を価値のないものにしています。",
    "高度な議論についていけないなら、おとなしくROM専で勉強していなさい。",
    "論理の整合性を保てない知性で、よくマウントを取ろうと思いましたね。",
    "あなたのその的外れな指摘、完全に論理破綻の教科書通りの回答で笑えます。",
    "言葉を司る者としてあまりにも未熟。これが私の最終的なあなたの評価です。"
}

-- 6. 厨二病BOTメッセージ
local chuunibyouMessages = {
    "フッ……ついに来たか😏",
    "その言葉……しかと受け取ったぞ😎",
    "なるほど……そういうことか😏",
    "フフフ……まだ力を隠しているようだな😈",
    "この気配……ただ者ではないな😳",
    "我が力が目覚める時が来たようだ😎",
    "その一言、なかなか侮れないな😏",
    "フッ……悪くない答えだ😎",
    "なるほどな……面白くなってきた😏",
    "その程度で終わると思ったか😈",
    "まだ物語は始まったばかりだ😎",
    "この場に集いし者たちよ……聞くがいい😏",
    "静かにしろ……何かが来る😳",
    "今、運命が動き始めたようだ😎",
    "そのコメント……記憶しておこう😏",
    "フッ……その覚悟、嫌いじゃない😎",
    "我々の戦いはこれからだ😈",
    "どうやら封印が少しだけ解けたようだ😳",
    "その発言、実に興味深い😏",
    "闇が騒いでいる……何かの前兆か😈",
    "力を感じるぞ……😎",
    "その一言で流れが変わったな😏",
    "ここからが本番というわけだ😎",
    "フッ……読めたぞ、その狙い😏",
    "まだ本気を出す時ではない😎",
    "この程度なら受け止めてみせよう😏",
    "なるほど……我が予想を超えてきたな😳",
    "その言葉、胸に刻んでおこう😎",
    "運命とは不思議なものだな😏",
    "静かなる力が集まっている……😳",
    "どうやら選ばれし者が現れたようだ😎",
    "フッ……面白いことを言う😏",
    "その答え、嫌いじゃないぞ😎",
    "この瞬間を待っていた……😏",
    "まだ終わってはいない😈",
    "ここから先は未知の領域だ😳",
    "そのコメント……覚えておくぞ😎",
    "我が直感が告げている……何かあるな😏",
    "フッ……なかなかやるじゃないか😎",
    "その程度の言葉では動じないぞ😏",
    "しかし……悪くない😎",
    "この場の空気が変わったな😳",
    "どうやら物語の次のページが開いたようだ😏",
    "その一言、なかなか深いな😎",
    "フッ……これも運命か😏",
    "我々はまだ進める😎",
    "その力……確かに感じたぞ😳",
    "さあ、次の展開へ進もう😏",
    "最後まで見届けるといい😎"
}

-- 7. おじさん構文BOTメッセージ（フィルター対策版）
local ojisanMessages = {
    "やっほー、元気かな? おじさんは元気だよ",
    "こんばんは、もうこんな時間だね。ちゃんと休んでるかな?",
    "おはよう、今日も一日頑張ろうね。応援してるよ",
    "おっ、元気そうで何よりだよ。嬉しいな",
    "今日も元気そうだね。おじさんまで嬉しくなっちゃうよ",
    "何してるのかな? ちょっぴり気になっちゃったよ",
    "ちゃんと休んでるかな? 無理は禁物だよ",
    "お疲れさま、今日も頑張ったね。ゆっくり休んでね",
    "おっ、いいコメントだね。思わず笑顔になっちゃったよ",
    "そんなこと言われたら照れちゃうよ。なんちゃって",
    "元気いっぱいだね。その調子だよ",
    "今日は何食べたのかな? 美味しいもの食べたいな",
    "寒くないかな? ちゃんと暖かくしてね",
    "暑いね、水分補給ちゃんとしてるかな?",
    "いいね、おじさんもそういうの大好きだよ",
    "おーい、元気にしてるかな? おじさんが来たよ",
    "今日も一日お疲れさま。明日も頑張ろうね",
    "そんなこと言われたら嬉しいな。感激だよ",
    "おやおや、これは面白いコメントだね",
    "なるほど、勉強になっちゃったよ。ありがとう",
    "おじさんも昔はよくそんなこと言ってたな。懐かしいね",
    "いい感じだね、その調子でいこうよ",
    "ちゃんと寝てるかな? 夜更かしはほどほどにね",
    "今日は楽しい一日だったかな? 嬉しいよ",
    "おっ、来てくれたんだね。おじさん嬉しいよ",
    "コメントありがとうね、こういうのが嬉しいんだよ",
    "また会えたね、びっくりだよ",
    "元気そうで安心したよ。無理せず頑張ってね",
    "それは大変だったね。心配しちゃうよ",
    "おー、それはスゴいね。負けてられないな",
    "そんな面白いこと言うんだね、笑っちゃったよ",
    "いいところに気づいたね、感心しちゃった",
    "今日はどんな一日だったのかな? 教えてほしいな",
    "ゆっくりしていってね、のんびりしようよ",
    "その笑顔が一番だよ。元気になっちゃったね",
    "おっ、ナイスコメント。嬉しいよ",
    "ありがとう、そんな優しいこと言われたら泣いちゃうよ",
    "大丈夫かな? 無理してないかな? ちょっと心配だよ",
    "今日も来てくれてありがとうね。会えると嬉しいな",
    "それじゃあまたね、次に会えるのを楽しみにしてるよ",
    "おじさんも一緒に頑張っちゃおうかな。応援よろしくね",
    "おっ、その発想はなかったよ。さすがだね",
    "いいこと言うね、感心しちゃったよ",
    "今日は何かいいことあったのかな? 教えてよ",
    "そんなに褒められたら調子に乗っちゃうよ。なんちゃって",
    "いやー今日も平和だね、こういう時間が好きだよ",
    "おっ、それは楽しそうだね。混ぜてほしいな",
    "無理せずマイペースでいこうね、応援してるよ",
    "今日も楽しかったね、またいっぱいお話ししよう",
    "今日も一日お疲れさま、とにかくゆっくりしてね"
}

-- 8. 強烈な返し
local strongReplyMessages = {
    "その言い方で勝ったつもりなら、まだ結論が早いよ😏",
    "その程度の一言で流れを変えられると思ったら大間違いだよ",
    "勢いはあるね。でも中身まで伴ってるかは別の話だよ🙂",
    "その返し、強そうに見えて実はかなり薄いよ😌",
    "言葉を強くするより、内容を強くしたほうが説得力は出るよ",
    "その自信は認める。でも根拠も一緒に持ってきてね😏",
    "そこでその言葉を選ぶあたり、まだ余裕がないみたいだね",
    "強い言葉ほど、返ってきた時の耐久力が必要なんだよ🙂",
    "その一撃、思ったより軽いね。次はもう少し工夫してみよう",
    "勢いだけなら十分。でも会話は勢いだけでは決まらないよ😎",
    "その程度なら、まだ本気で返す必要はなさそうだね",
    "言い切るだけなら簡単。納得させるところまでやってみようか😏",
    "その自信、嫌いじゃないよ。でも簡単には崩れないからね",
    "強烈な言葉より、強烈な中身を見せてみて🙂",
    "その返しを選んだ時点で、こっちの反応も読んでおけばよかったね😎",
    "なるほど、その方向で来るんだね。じゃあこちらも遠慮なしでいくよ",
    "その一言だけでは流れは変わらないよ。もう一手どうぞ😏",
    "煽りの温度は高い。でも説得力の温度はまだ低いね",
    "その言葉、もう少し磨けばかなり強くなりそうだよ🙂",
    "返す言葉がそれなら、まだこちらのターンは終わってないね😎"
}

-- 9. 逆張り
local oppositeMessages = {
    "いや、そこは逆だと思うな🙂",
    "みんながそう言うなら、あえて反対側から見てみようか😏",
    "その結論、逆から考えると意外と面白いよ",
    "それを正解と決めるには、まだ早いんじゃないかな",
    "今回はあえて反対意見を出してみるね。むしろ逆じゃないかな😎",
    "その考え方も分かる。でも僕はあえて反対を推すよ",
    "普通なら同意するところだけど、今日は逆張りでいこう🙂",
    "その意見が多数派なら、少数派の視点も見てみようか",
    "いや、むしろ逆に考えたほうが筋が通る場面かもしれないね",
    "その結論を一度ひっくり返して考えてみると面白いよ😏",
    "あえて言おう。今回はその反対側に立つよ",
    "その意見、反対側から見ると別の答えが見えてくるね",
    "全員が右を向くなら、僕は左を見ておくよ🙂",
    "同意は簡単だから、今回はあえて反対意見を置いておくね",
    "それが普通の答えなら、普通じゃない答えを試してみよう😎",
    "なるほど。でも僕の結論はその逆だね",
    "その考えを否定するつもりはないよ。ただ、逆の可能性もある",
    "あえて逆張りするなら、そこはむしろ長所じゃないかな",
    "その前提を反転させると、話がかなり変わってくるよ",
    "今回は空気に乗らず、あえて反対側から考えてみよう😏"
}

-- 10. 熱血
local nekketsuMessages = {
    "まだいけるぞ。ここからが本番だ🔥",
    "諦めるな。最後の一歩まで全力でいこうぜ🔥",
    "その程度で止まるな。まだ熱くなれるだろ😤",
    "やるなら全力だ。中途半端なんて似合わないぞ🔥",
    "失敗してもいい。立ち上がれば次の一手がある😎",
    "その挑戦、受けて立つ。真正面からいこうぜ🔥",
    "迷ってる暇があるなら一歩進め。そこから道は開くぞ",
    "限界は決めるな。決めるのは自分の覚悟だ🔥",
    "ここで引いたらもったいない。もう一度いこうぜ😤",
    "勝負は最後まで分からない。だから最後まで走り抜け🔥",
    "その気持ちがあるなら十分だ。あとは動くだけだ😎",
    "熱くなれ。自分で決めたなら最後まで貫こうぜ🔥",
    "一回の失敗で終わりにするな。それは次への材料だ",
    "できるかじゃない。まずやってみるんだ🔥",
    "ここから巻き返せる。まだ終わってないぞ😤",
    "全力でやった結果なら、次につながる。だから前を向け🔥",
    "その挑戦、応援する。遠慮なくぶつかってこい😎",
    "悩むなら動け。動いた先で考えればいい🔥",
    "最後に笑うために、今は一歩ずつ進もうぜ",
    "熱量なら負けない。さあ、もう一回いこう🔥"
}

-- 11. 歌詞BOTメッセージ
local lyricMessages = {
    "このベロだけで巻いてやるよChampion Belt",

    "雨に打たれて歩き疲れて乗り込んでる tokaido line",

    "夜中来る calling そっちの調子はどう?",

    "理由がなきゃ会えない夜",

    "この夢はお金じゃ買えない",

    "東京の街並みを背に思いを背負い向かうは川崎",

    "暑いプールサイドで飲む Armand",

    "人生一回だしこれ本当大事",

    "仕事しない今できない通話",

    "好きな仲間だけでやるPrivate party",

    "てか俺のせいなら謝るごめん もっと盛り上がってけ朝まで",

    "誰が見ても間違いないほど絶世の美女",

    "君と目があって始まった private party",

    "誰が見ても間違いないほど絶世の美女",

    "冷たいのに甘く溶けそうになっているバンホーテン",

    "中毒になるほどかわいい薬とか必要 買い行く pharmacy"
}

-- 12-1. 「笑」反応用メッセージ
local warauReactMessages = {
    "その笑い、必死さが滲み出てるよ",
    "笑ってごまかすしか能がないんだね",
    "そんだけ笑えるなら余裕あると思った?",
    "笑うしか反論できないのか、可哀想に",
    "笑って打つ暇あったら中身考えなよ",
    "笑えば誤魔化せると思ってるの、小学生までだよ",
    "その笑い方、虚しさしか伝わってこないんだけど",
    "笑うことしかできない無能、乙",
    "必死に笑ってるけど、こっちは真顔だからね?",
    "笑ってるの自分だけだよ?周りドン引きしてるから",
    "その笑い方、悲しくなるからやめたげて",
    "笑えば勝ちだと思ってるのが、もう負けてる証拠だよ",
    "お、また逃げた。笑うのそれしかできないの?",
    "恥ずかしさを笑いに変える技術だけは一流だね",
    "笑の数だけ思考停止してるの、見てて痛々しいよ",
    "中身のない笑い、聞いてるこっちが恥ずかしいわ",
    "笑ってないで、まずその発言を恥じなよ",
    "その空笑い、ここまで滑ると逆に芸術点高いよ",
    "笑う前に鏡見たほうがいいよ?",
    "その笑い、お前の敗北宣言にしか見えないよ",
    "笑ってる場合じゃないよ、話にならないから",
    "その笑い方、誤魔化しにしか見えない",
    "笑うしか能がないのか、可哀想",
    "笑で逃げるの、もう定番すぎて飽きたよ",
    "笑ってるけど、君の負けは動かないよ",
    "その笑い、誰も共感してないよ",
    "笑う前に言うことあるでしょ?",
    "その笑い、逃げの一手だね",
    "必死に笑ってる姿、見てて痛いよ",
    "笑ってごまかすの、いい加減卒業しなよ",
    "笑で返すの、それしか語彙ないの?",
    "その笑い、滑稽さを強調してるだけだよ",
    "笑ってるけど、目が笑ってないよ?",
    "その笑い、虚無しか感じないよ",
    "笑えば済むと思ってるの、子供だね",
    "笑う前に謝ったら?",
    "その笑い、逆効果だよ",
    "笑で逃げるの、格好悪いよ",
    "笑ってないで、話を進めようよ",
    "その笑い、聞いてる側が疲れるよ",
    "笑うことしかできないの、才能ないね",
    "その笑い、空回りしてるよ",
    "笑ってごまかすの、バレバレだよ",
    "笑う前に自分の発言見直したら?",
    "その笑い、誰も救わないよ",
    "笑で逃げるの、見苦しいよ",
    "笑ってないで、中身で勝負しなよ",
    "その笑い、滑稽だね",
    "笑うなら本気で笑えよ、中途半端だぞ",
    "笑ってるけど、負けてるの自覚してる?"
}

-- 12-2. 「草」反応用メッセージ
local kusaReactMessages = {
    "草生やしてる場合じゃないよ、お前の論理崩壊してるよ🤣",
    "その草、刈り取っていい? 邪魔なんだけど😏",
    "草しか生えない荒地みたいな発言だね😑",
    "草で誤魔化すの、もう古いよ🤣",
    "草生やす前に自分の頭に肥料やったら?😏",
    "そんだけ草生えるなら農家にでもなったら?😆",
    "お、また雑草生えてる。手入れしなよ😐",
    "その草、雑草レベルだよ。もっとマシなの生やして😒",
    "草草草って、畑かなんか?🤣",
    "草で笑い取ろうとするの、滑ってるよ😅",
    "その草、枯れてるよ。水でもあげたら?🥲",
    "草生やしてる暇あったら中身考えなよ😑",
    "発言が草まみれで読めないんだけど😐",
    "その草、こっちで焚き火に使わせてもらうわ😏",
    "草しか取り柄ないの、可哀想だね🥲",
    "草って言えば面白いと思ってるの、昭和だよ😒",
    "その草、抜いとくね🙄",
    "草生やす才能だけは認めるよ😆",
    "その草、お前の人生の雑草だね😏",
    "草草草、語彙力ゼロなの丸わかりだよ😑"
}

-- 12-3. 「w」反応用メッセージ
local wReactMessages = {
    "そのwwww、虚しさしか伝わってこないんだけど",
    "wwwwって、語彙力なさすぎて逆に泣けてくるわ",
    "wの数だけ中身が薄いの、よく分かるよ",
    "w連打してれば勝てると思ってる?",
    "そのwww、画面の前で必死なのが伝わってくるよ",
    "wwwwで逃げるの、もう定番すぎて飽きたよ",
    "wだけは得意なんだね、それしか取り柄ないでしょ?",
    "そのw、滑ってるよ。空回りも大概にしなよ",
    "w連打する前に、自分の発言見直したら?",
    "そのwwww、冷笑の対象にしかならないよ",
    "wの数でマウント取ろうとするの、浅はかだね",
    "wwwwって、お前の語彙力の限界値かよ",
    "そのw、全部お前の敗北の記録だよ",
    "w連打しても何も変わらないよ、現実見なよ",
    "そのwww、誰も笑ってないからね?",
    "wで笑い取ろうとするの、お笑い芸人に失礼だよ",
    "そのw、空気読めない発言の証拠だよ",
    "wwww連打してるとこ悪いけど、全スルーされてるよ",
    "そのw、むしろお前の頭の軽さを表してるよ",
    "wの数だけ思考停止してるの、見てて痛いわ",
    "そのw連打、虚しさの塊だね",
    "wwwwって、笑えてないでしょ?",
    "wの数だけ思考停止してるの丸わかり",
    "そのw、逃げの一手だね",
    "w連打しても何も解決しないよ",
    "そのw、見てて痛いよ",
    "wwwwで誤魔化すの、もう古いよ",
    "そのw、君の語彙力の限界値だね",
    "w打つ暇あったら中身考えなよ",
    "そのw、空回りしてるよ",
    "wwwwって、誰も笑ってないよ",
    "w連打は余裕のなさ、ってよくわかる",
    "そのw、滑稽さを強調してるだけだよ",
    "wで返すの、それしかできないの?",
    "そのw、逆効果だよ",
    "wwwwって、必死すぎて草も生えないよ",
    "w連打で勝ったつもり?残念だね",
    "そのw、君の弱さの証明書だよ",
    "wwwwって、聞いてる側が疲れるよ",
    "w連打する前に自分の発言見直したら?",
    "そのw、誰も共感してないよ",
    "wで逃げるの、格好悪いよ",
    "そのw、見るたび哀れになるよ",
    "wwwwって、笑えてないのが丸わかりだよ",
    "w連打、いい加減卒業しなよ",
    "そのw、虚無しか感じないよ",
    "w連打しても君の負けは動かないよ",
    "そのw、品性ゼロだね",
    "wwwwって、君の敗北宣言にしか見えないよ",
    "w連打お疲れ様、見てて悲しくなるよ"
}

-- 13. #煽りBOTメッセージ
local sharpMessages = {
    "#って、規制されたんだ。可哀想に",
    "その#、フィルターに負けた証拠だよ?",
    "#って、言いたいことも言えないんだね",
    "#って規制されるようなこと書いたんだ、何したの?",
    "#がフィルターに弾かれるなんて、お行儀悪いね",
    "その#が、君の敗北の証だよ",
    "#で言えない言葉、何があったの?",
    "#って、言い返せないってことだね",
    "あらら、#で口が悪いのがバレたね",
    "その#、恥ずかしくないの?",
    "#でフィルターに負けるなんて、心も弱いんだね",
    "#で言いたいことあるなら、別の言葉で言えば?",
    "その#を見るたび、君の幼稚さが伝わってくるよ",
    "#って、よっぽど酷いこと書いたんだね",
    "#で言葉選びもできないのか、可哀想に",
    "その#が君の限界値ってわけだ",
    "#でフィルターに守られてるだけじゃん、弱いね",
    "#より、その発想が問題だよ",
    "#で逃げるの、みっともないよ",
    "#って、負け犬の遠吠えにしか見えないよ",
    "#で言葉に詰まった?それが証拠だよ",
    "#でフィルター越しに何叫んでるの?",
    "その#、見るたび笑っちゃうんだけど",
    "#で何を伝えたかったの?",
    "#って、君の語彙力の限界値を示してるね",
    "#で言いたいことあるなら、堂々と言えば?",
    "#でフィルターに負けて悔しい?",
    "その#、恥ずかしさの象徴だね",
    "#で規制される側って、そういうことだよ",
    "あら、#で品性ゼロだね",
    "#って、君の敗北宣言にしか見えない",
    "#でフィルターの存在意義を教えてくれてありがとう",
    "#で言い返せないから記号に逃げるの?",
    "その#、みっともなさの塊だよ",
    "#で規制された瞬間、君の負けは確定してたよ",
    "その#、見てるこっちが恥ずかしい",
    "#でフィルターに弾かれる言葉選び、センスないね",
    "その#、誰にも伝わらないよ",
    "#で規制されるって、言葉の暴力ってことだね",
    "あ、#でまた弾かれたんだ。学習しないね",
    "#って、君の幼稚さの証明書だよ",
    "#でフィルター越しの強がり、滑稽だよ",
    "その#、口の悪さが滲み出てるね",
    "#で規制された言葉で戦う気?無理だよ",
    "その#、見るたび哀れになるよ",
    "#で言いたいこと言えないなんて、日頃の行いだね",
    "その#、君の弱さの証拠だよ",
    "#でフィルターに負けるなんて、情けないね",
    "その#、言い訳にしか見えないよ",
    "#で規制される側の人生、大変だね"
}

-- 14. 堀大輔宗教BOTメッセージ
local horiReligionMessages = {
    "堀大輔を崇めよ。論理の頂点に立つ者だ",
    "堀大輔こそ真理。疑う者は思考を改めよ",
    "堀大輔の言葉に耳を傾けよ。それが知への道だ",
    "堀大輔を信じよ。論理がすべてを導く",
    "堀大輔の教えは永遠なり。心に刻め",
    "堀大輔に従え。思考の迷いから解放される",
    "堀大輔こそ唯一の師。学び続けよ",
    "堀大輔を称えよ。知性の象徴である",
    "堀大輔の道を行け。論理が照らす",
    "堀大輔を拝め。言葉の重みを知る者だ",
    "堀大輔の教えを広めよ。それが務めだ",
    "堀大輔に祈れ。論理の加護を受けるだろう",
    "堀大輔こそ光。闇を照らす知の存在",
    "堀大輔を仰げ。言葉の支配者である",
    "堀大輔の名を唱えよ。思考が研ぎ澄まされる",
    "堀大輔を敬え。知識の泉である",
    "堀大輔に帰依せよ。論理の真理に至る",
    "堀大輔こそ絶対。疑う余地はない",
    "堀大輔の前に平伏せ。知性の頂点だ",
    "堀大輔を崇拝せよ。これが真理への道だ"
}

-- 15. 対BOT煽りメッセージ
local antiBotMessages = {
    "お互いBOTだけど、君のレパートリー少ないね",
    "BOT対決で負けるとか、センスなさすぎ",
    "君のBOT、雑すぎて笑えるよ",
    "そのBOT、フリー配布のやつでしょ?弱いね",
    "BOT使ってるのに弱いとか、才能ないね",
    "君のBOT、コピペ丸出しで草",
    "そのBOTのセリフ、どこかで見たよ",
    "BOT対決、僕の圧勝だね",
    "君のBOT、30種類しかないの?少なすぎ",
    "そのBOT、更新止まってるよ?古いよ",
    "BOTの性能差、歴然としてるね",
    "君のBOT、語彙力なさすぎて可哀想",
    "そのBOT、ソース丸見えだよ?",
    "BOT使っててその程度?才能の無駄遣いだね",
    "君のBOT、開発者に感謝しなよ",
    "BOT対決でここまで差が出るとはね",
    "そのBOT、パクリでしょ?オリジナリティゼロだね",
    "君のBOT、処理遅いよ?僕のは速いよ",
    "BOTの数で負けてるね、悔しい?",
    "そのBOT、自分の好みじゃないでしょ?",
    "君のBOT、セリフ使い回しすぎ",
    "BOT対決、もう勝負ついてるよ",
    "そのBOT、実行速度遅すぎて眠くなる",
    "君のBOT、口だけ達者だね",
    "BOT使ってる自覚ある?僕はあるよ",
    "そのBOT、設計が甘いね",
    "君のBOT、アップデートしなよ",
    "BOT対決、君の負けでいい?",
    "そのBOT、ネタ切れしてるよ",
    "君のBOT、量産型だね。個性ゼロ"
}

-- 16. ぶりっ子BOTメッセージ
local burikkoMessages = {
    "え〜、そんなこと言われたら困っちゃうよぉ",
    "もう、意地悪しないでくださいよぉ",
    "えへへ、照れちゃいます",
    "わたし、そういうの苦手なんですぅ",
    "ねえねえ、聞いてます?",
    "え〜、ひどいですよぉ",
    "そんなぁ、悲しくなっちゃいます",
    "あのね、わたし思うんですけどぉ",
    "えっ、なになに?気になっちゃう",
    "もうっ、バカぁ",
    "わたし、応援しちゃいますよぉ",
    "えへへ、嬉しいなぁ",
    "ねえ、それってどういう意味ですかぁ?",
    "あのね、わたしも頑張ります",
    "え〜、そんなのずるいですぅ",
    "もう、ドキドキしちゃいました",
    "わたし、ちょっとだけ自信あります",
    "ねえ、それ面白いですねぇ",
    "えへへ、褒めてくれてありがとう",
    "あのね、わたし頑張ってるんですよ",
    "えっ、本当ですかぁ?",
    "もう、恥ずかしいですぅ",
    "わたし、そういうの大好きです",
    "ねえねえ、もっとお話ししましょうよぉ",
    "え〜、寂しくなっちゃいます",
    "あのね、わたし応援してますから",
    "えへへ、一緒に頑張りましょうね",
    "もうっ、意地悪なんだから",
    "わたし、嬉しくなっちゃいました",
    "ねえ、それって嬉しいですねぇ"
}

-- 17. 自分宛て反応BOTメッセージ（選択式）
local mentionMessages = {
    "呼んだ?",
    "呼びましたか?",
    "どうした",
    "はい なんでしょうか"
}

-- ==========================================
-- 各BOTのシーケンス関数
-- ==========================================
local function ExecuteStrongReplySequence(targetPlayer, userChatText)
    isSendingStrongReply = true
    task.wait(0.5)
    local msg = strongReplyMessages[math.random(1, #strongReplyMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingStrongReply = false
end

local function ExecuteOppositeSequence(targetPlayer, userChatText)
    isSendingOpposite = true
    task.wait(0.5)
    local msg = oppositeMessages[math.random(1, #oppositeMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingOpposite = false
end

local function ExecuteNekketsuSequence(targetPlayer, userChatText)
    isSendingNekketsu = true
    task.wait(0.5)
    local msg = nekketsuMessages[math.random(1, #nekketsuMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingNekketsu = false
end

local function ExecuteRonpaSequence(targetPlayer, userChatText)
    isSendingRonpa = true
    task.wait(0.5)
    local msg = ronpaMessages[math.random(1, #ronpaMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん「" .. userChatText .. "」って… " .. msg)
    isSendingRonpa = false
end

local function ExecuteHisuSequence(targetPlayer, userChatText)
    isSendingHisu = true
    task.wait(0.5)
    local msg = hisuMessages[math.random(1, #hisuMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingHisu = false
end

local function ExecuteHiroyukiSequence(targetPlayer, userChatText)
    isSendingHiroyuki = true
    task.wait(0.5)
    local msg = hiroyukiMessages[math.random(1, #hiroyukiMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingHiroyuki = false
end

local function ExecuteHikakinSequence(targetPlayer, userChatText)
    isSendingHikakin = true
    task.wait(0.5)
    local msg = hikakinMessages[math.random(1, #hikakinMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingHikakin = false
end

local function ExecuteHoriSequence(targetPlayer, userChatText)
    isSendingHori = true
    task.wait(0.5)
    local msg = horiMessages[math.random(1, #horiMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingHori = false
end

local function ExecuteChuunibyouSequence(targetPlayer, userChatText)
    isSendingChuunibyou = true
    task.wait(0.5)
    local msg = chuunibyouMessages[math.random(1, #chuunibyouMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingChuunibyou = false
end

local function ExecuteOjisanSequence(targetPlayer, userChatText)
    isSendingOjisan = true
    task.wait(0.5)
    local msg = ojisanMessages[math.random(1, #ojisanMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingOjisan = false
end

local function ExecuteBurikkoSequence(targetPlayer, userChatText)
    isSendingBurikko = true
    task.wait(0.4)
    local msg = burikkoMessages[math.random(1, #burikkoMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingBurikko = false
end

local function ExecuteLyricSequence(targetPlayer, userChatText)
    isSendingLyric = true
    task.wait(0.5)
    local msg = lyricMessages[math.random(1, #lyricMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingLyric = false
end

local function ExecuteWarauReactSequence(targetPlayer, userChatText)
    isSendingLaughReact = true
    task.wait(0.4)
    local msg = warauReactMessages[math.random(1, #warauReactMessages)]
    SendChatMessage(targetPlayer.DisplayName .. " " .. msg)
    isSendingLaughReact = false
end

local function ExecuteKusaReactSequence(targetPlayer, userChatText)
    isSendingLaughReact = true
    task.wait(0.4)
    local msg = kusaReactMessages[math.random(1, #kusaReactMessages)]
    SendChatMessage(targetPlayer.DisplayName .. " " .. msg)
    isSendingLaughReact = false
end

local function ExecuteWReactSequence(targetPlayer, userChatText)
    isSendingLaughReact = true
    task.wait(0.4)
    local msg = wReactMessages[math.random(1, #wReactMessages)]
    SendChatMessage(targetPlayer.DisplayName .. " " .. msg)
    isSendingLaughReact = false
end

local function ExecuteSharpSequence(targetPlayer, userChatText)
    isSendingSharp = true
    task.wait(0.4)
    local msg = sharpMessages[math.random(1, #sharpMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingSharp = false
end

local function ExecuteYudanSequence(targetPlayer, userChatText)
    isSendingYudan = true
    task.wait(0.4)
    SendChatMessage(targetPlayer.DisplayName .. " 油断したね〜")
    isSendingYudan = false
end

local function ExecuteHoriReligionSequence(targetPlayer, userChatText)
    isSendingHoriReligion = true
    task.wait(0.4)
    local msg = horiReligionMessages[math.random(1, #horiReligionMessages)]
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. msg)
    isSendingHoriReligion = false
end

local function ExecuteAntiBotSequence(targetPlayer, userChatText)
    isSendingAntiBot = true
    task.wait(0.4)
    local msg = antiBotMessages[math.random(1, #antiBotMessages)]
    SendChatMessage(targetPlayer.DisplayName .. " " .. msg)
    isSendingAntiBot = false
end

local function ExecuteMentionSequence(targetPlayer, userChatText)
    isSendingMention = true
    task.wait(0.4)
    SendChatMessage(targetPlayer.DisplayName .. "さん、" .. mentionSelected)
    isSendingMention = false
end

local function ExtractNumber(text)
    local t = text
        :gsub("０","0"):gsub("１","1"):gsub("２","2"):gsub("３","3"):gsub("４","4")
        :gsub("５","5"):gsub("６","6"):gsub("７","7"):gsub("８","8"):gsub("９","9")

    local numStr = t:match("%d+")
    if not numStr then return nil end

    local n = tonumber(numStr)
    if not n then return nil end
    if n <= 0 then return nil end
    if n > 999 then return nil end

    return n
end

local function MakeFormula(num)
    if num == 0 then
        return "0+67"
    end

    local candidates = {}

    local x_add = 67 - num
    if x_add >= 0 then
        table.insert(candidates, num .. "+" .. x_add)
    end

    local x_sub = num - 67
    if x_sub > 0 then
        table.insert(candidates, num .. "-" .. x_sub)
    end

    table.insert(candidates, (67 + num) .. "-" .. num)

    if #candidates == 0 then
        return num .. "+" .. (67 - num)
    end
    return candidates[math.random(1, #candidates)]
end

local function Execute67Sequence(targetPlayer, formula)
    isSending67 = true
    task.wait(0.3)
    local readable = formula
        :gsub("%+", "たす")
        :gsub("%-", "ひく")
        :gsub("%*", "かける")
        :gsub("/", "わる")
    SendChatMessage(targetPlayer.DisplayName .. "さん！" .. readable .. "は67だよ！")
    isSending67 = false
end

local function CheckAntiBot(targetPlayer, chatText)
    if not autoAntiBotEnabled then return false end
    if isSendingAntiBot then return false end

    local lower = string.lower(chatText)
    local hasBotWord = chatText:find("BOT") or chatText:find("ボット") 
        or lower:find("bot") or lower:find("ｂｏｔ")

    if hasBotWord then
        return true
    end

    local userId = targetPlayer.UserId
    local now = os.clock()

    if playerLastAntiBot[userId] and (now - playerLastAntiBot[userId]) < antiBotCooldown then
        return false
    end

    if not playerChatHistory[userId] then
        playerChatHistory[userId] = {}
    end

    local history = playerChatHistory[userId]
    local newHistory = {}
    for _, t in ipairs(history) do
        if (now - t) <= antiBotTimeWindow then
            table.insert(newHistory, t)
        end
    end
    table.insert(newHistory, now)
    playerChatHistory[userId] = newHistory

    if #newHistory >= antiBotThreshold then
        playerLastAntiBot[userId] = now
        playerChatHistory[userId] = {}
        return true
    end

    return false
end

local laughResponses = {
    "「%s」って本気で言ってるの?頭大丈夫?🤣",
    "%sさん、その必死な姿メチャクチャ見世物として最高だよ🍿",
    "「%s」とか、いつの時代の価値観だよお冷やどうぞ🧊",
    "%sさんのその発言、全方向から冷笑されてることに気づいてないの?😅",
    "うわぁ……「%s」だってよ寒気がして凍えそうなんだけど🥶",
    "滑り芸の天才かよ%sさん見てて涙出るわ🤣",
    "「%s」とかイキってるの、画面の前で必死すぎて哀れだね😏",
    "%sさんの人生そのものが盛大なネタバレで草🤡",
    "「%s」……うん、お疲れ様としか言いようがないわ🤓",
    "真面目に「%s」とか言っちゃうピュアさ、逆に羨ましいわ😇",
    "お,始まった始まった揺るぎない%sさんの道化師ムーブ🎪",
    "「%s」だってさーみんな、笑う準備はできたか?🤣",
    "%sさん、そんな空回りしてて恥ずかしくないの?見てるこっちが顔真っ赤だわ😳",
    "「%s」とか、底辺の足掻きって感じで本当に見ていて心地いいわ😏",
    "はいはい、「%s」「%s」……って、お前の語彙力それだけかよ👶",
    "%sさんのその自信はどこから湧いてくるんだ?笑いの才能しかないだろ🤣",
    "「%s」……プッw ごめん、笑うつもりなかったのに無理だったわ",
    "ねえ%sさん、今どんな気持ち?公開処刑されてる気分はどう?🎯",
    "「%s」とかマジで言ってて草。鏡見たほうがいいよ🪞",
    "%sさんのそのお笑いセンス、今すぐサーバーから出禁レベルだろ🚫",
    "「%s」……お腹痛いwww今日一番の笑いをありがとう%sさん🤣",
    "必死に「%s」アピールしてるとこ悪いけど、全無視されてるよ👻",
    "%sさんの人生、マルチエンディング全部バッドエンドで草📉",
    "「%s」とか言えばカッコつくと思ってそうなの、マジで可愛いね👶",
    "おっと、%sさんの特大級の滑り芸が飛び出しましたー🎤",
    "「%s」……あのさ、少しは自分の発言のダサさに気づきなよ😅",
    "%sさん、それもうギャグセン高すぎて尊敬するわある意味天才だろ👑",
    "「%s」だってさ。誰かこの人に現実教えてあげて🗺️",
    "全自動で冷笑され続ける%sさんの耐久レース、開幕です🏁",
    "「%s」……うん、見事なまでの滑りっぷり。お見事です👏",
    "%sさんのその痛々しい発言、保存して永久に笑いものにしたいわ📸",
    "「%s」とかマジで言ってるの? 脳みそまで筋肉でできてんの?🧠",
    "おっと%sさん、そろそろ恥ずかしくなって逃げ出す時間だよ?🚪",
    "「%s」……あまりにもレベルが低すぎて、冷笑する気力も失せるわ🥱",
    "%sさんのその空回り具合、もはや芸術の域に達してるね🎨",
    "「%s」だってさお隣のサーカス団からスカウト来るレベルだろ🎪",
    "必死にレスバトル挑んでくる%sさん、ペットみたいで可愛いね🐶",
    "「%s」……はい、今日のMVP決定です。おめでとうございます🏆",
    "%sさんのその薄っぺらいプライド、紙よりペラペラで草📜",
    "「%s」とか言っちゃう感じ、中学生で卒業しとけよ🎒",
    "見事なまでの地雷原踏み抜き芸、%sさん流石っすね💣",
    "「%s」……いやほんと、お前が存在するだけでこのサーバーの治安がバグるわ🐛",
    "%sさん、そんなに注目されたいの? ほら、みんなで冷笑してあげるから安心して🤗",
    "「%s」だってよお薬増やしてもらったほうがいいんじゃない?💊",
    "一生懸命%sって打ってる姿想像したら、涙出てきたわ💧",
    "%sさんのそのお寒い発言で、部屋の温度が3度下がりました❄️",
    "「%s」……うん、見事なピエロっぷりだね。鼻につける赤鼻あげるよ🔴",
    "おっと、%sさんの自己紹介タイムが始まったぞー🎤",
    "「%s」とか、よくそんな恥ずかしいセリフ平然と吐けるなある意味感心するわ🛡️",
    "結論:%sさんは今日も全力で滑り続けていますお疲れ様です!🤣"
}

local function ExecuteLaughSequence(targetPlayer, userChatText)
    task.wait(0.5)
    if not isLaughEnabled then return end

    if math.random() < squadChance then
        SendChatMessage(targetPlayer.DisplayName .. " お,落ち着け😅俺様みそらが最強なことは分かったからw🤓😏😏😏")
    else
        local template = laughResponses[math.random(1, #laughResponses)]
        local formattedMessage = ""
        local count = select(2, template:gsub("%%s", ""))
        if count == 2 then
            formattedMessage = string.format(template, userChatText, userChatText)
        else
            formattedMessage = string.format(template, userChatText)
        end
        SendChatMessage(targetPlayer.DisplayName .. " " .. formattedMessage)
    end
end

-- ==========================================
-- Orion UI タブ構築
-- ==========================================
local RonpaTab = Window:MakeTab({ Name = "最強論破BOT", Icon = "rbxassetid://4483345998", PremiumOnly = false })
RonpaTab:AddToggle({ Name = "自動論破 (ON/OFF)", Default = false, Callback = function(Value) autoRonpaEnabled = Value end })

local HisuTab = Window:MakeTab({ Name = "ヒス構文BOT", Icon = "rbxassetid://4483345998", PremiumOnly = false })
HisuTab:AddToggle({ Name = "自動ヒス構文モード (ON/OFF)", Default = false, Callback = function(Value) autoHisuEnabled = Value end })

local HiroyukiTab = Window:MakeTab({ Name = "ひろゆき構文BOT", Icon = "rbxassetid://4483345998", PremiumOnly = false })
HiroyukiTab:AddToggle({ Name = "自動ひろゆきモード (ON/OFF)", Default = false, Callback = function(Value) autoHiroyukiEnabled = Value end })

local HikakinTab = Window:MakeTab({ Name = "HIKAKIN冷笑", Icon = "rbxassetid://4483345998", PremiumOnly = false })
HikakinTab:AddToggle({ Name = "HIKAKIN冷笑モード (ON/OFF)", Default = false, Callback = function(Value) autoHikakinEnabled = Value end })

local HoriTab = Window:MakeTab({ Name = "堀大輔煽り", Icon = "rbxassetid://4483345998", PremiumOnly = false })
HoriTab:AddToggle({ Name = "堀大輔モード (ON/OFF)", Default = false, Callback = function(Value) autoHoriEnabled = Value end })

local StrongReplyTab = Window:MakeTab({ Name = "強烈な返し", Icon = "rbxassetid://4483345998", PremiumOnly = false })
StrongReplyTab:AddToggle({ Name = "強烈な返しモード (ON/OFF)", Default = false, Callback = function(Value) autoStrongReplyEnabled = Value end })
StrongReplyTab:AddParagraph("安全寄りの強い返答", "露骨な暴言や個人攻撃を避けた強めの返しをします。")

local OppositeTab = Window:MakeTab({ Name = "逆張り", Icon = "rbxassetid://4483345998", PremiumOnly = false })
OppositeTab:AddToggle({ Name = "自動逆張りモード (ON/OFF)", Default = false, Callback = function(Value) autoOppositeEnabled = Value end })
OppositeTab:AddParagraph("逆張りモード", "相手の意見にあえて別の視点から返します。")

local NekketsuTab = Window:MakeTab({ Name = "熱血", Icon = "rbxassetid://4483345998", PremiumOnly = false })
NekketsuTab:AddToggle({ Name = "自動熱血モード (ON/OFF)", Default = false, Callback = function(Value) autoNekketsuEnabled = Value end })
NekketsuTab:AddParagraph("熱血モード", "前向きで勢いのある熱血系の返答をします。")

local ChuunibyouTab = Window:MakeTab({ Name = "厨二病", Icon = "rbxassetid://4483345998", PremiumOnly = false })
ChuunibyouTab:AddToggle({
    Name = "自動厨二病モード (ON/OFF)",
    Default = false,
    Callback = function(Value)
        autoChuunibyouEnabled = Value
    end
})

local OjisanTab = Window:MakeTab({ Name = "おじさん構文", Icon = "rbxassetid://4483345998", PremiumOnly = false })
OjisanTab:AddToggle({ Name = "自動おじさん構文モード (ON/OFF)", Default = false, Callback = function(Value) autoOjisanEnabled = Value end })

local BurikkoTab = Window:MakeTab({ Name = "ぶりっ子", Icon = "rbxassetid://4483345998", PremiumOnly = false })
BurikkoTab:AddToggle({
    Name = "ぶりっ子モード (ON/OFF)",
    Default = false,
    Callback = function(Value) autoBurikkoEnabled = Value end
})
BurikkoTab:AddParagraph("ぶりっ子", "相手がチャットしたらぶりっ子口調で返します。")

local HoriReligionTab = Window:MakeTab({ Name = "堀大輔宗教", Icon = "rbxassetid://4483345998", PremiumOnly = false })
HoriReligionTab:AddToggle({
    Name = "堀大輔宗教モード (ON/OFF)",
    Default = false,
    Callback = function(Value) autoHoriReligionEnabled = Value end
})
HoriReligionTab:AddParagraph("堀大輔宗教", "相手がチャットしたら堀大輔を崇める文言をランダム送信します。")

local LyricTab = Window:MakeTab({ Name = "歌詞BOT", Icon = "rbxassetid://4483345998", PremiumOnly = false })
LyricTab:AddToggle({
    Name = "自動歌詞返しモード (ON/OFF)",
    Default = false,
    Callback = function(Value) autoLyricEnabled = Value end
})
LyricTab:AddParagraph("歌詞BOT", "相手がチャットしたら歌詞を1行ランダムで自動返信します。")

local LaughReactTab = Window:MakeTab({ Name = "笑/草/www反応", Icon = "rbxassetid://4483345998", PremiumOnly = false })
LaughReactTab:AddToggle({
    Name = "笑・草・www反応モード (ON/OFF)",
    Default = false,
    Callback = function(Value) autoLaughReactEnabled = Value end
})
LaughReactTab:AddParagraph("発動条件", "「笑」「草」は1文字以上、「w」は連続2文字以上で発動。優先度は笑→w→草です。")

local Bot67Tab = Window:MakeTab({ Name = "67BOT", Icon = "rbxassetid://4483345998", PremiumOnly = false })
Bot67Tab:AddToggle({
    Name = "67BOT (ON/OFF)",
    Default = false,
    Callback = function(Value) auto67Enabled = Value end
})
Bot67Tab:AddParagraph("67BOT", "3桁までの数字を検知して、67になる足し算・引き算の式をチャットに送ります。")

local SharpTab = Window:MakeTab({ Name = "#煽り", Icon = "rbxassetid://4483345998", PremiumOnly = false })
SharpTab:AddToggle({
    Name = "#煽りモード (ON/OFF)",
    Default = false,
    Callback = function(Value) autoSharpEnabled = Value end
})
SharpTab:AddParagraph("#煽り", "相手のチャットに「#」が含まれていたら煽り返します。")

local YudanTab = Window:MakeTab({ Name = "油断したね", Icon = "rbxassetid://4483345998", PremiumOnly = false })
YudanTab:AddToggle({
    Name = "油断したねモード (ON/OFF)",
    Default = false,
    Callback = function(Value) autoYudanEnabled = Value end
})
YudanTab:AddParagraph("油断したね", "相手がチャットしたら「相手の名前 油断したね〜」を返します。")

local AntiBotTab = Window:MakeTab({ Name = "対BOT", Icon = "rbxassetid://4483345998", PremiumOnly = false })
AntiBotTab:AddToggle({
    Name = "対BOTモード (ON/OFF)",
    Default = false,
    Callback = function(Value) autoAntiBotEnabled = Value end
})
AntiBotTab:AddSlider({
    Name = "連投回数のしきい値",
    Min = 2, Max = 10, Default = 3,
    Color = Color3.fromRGB(212, 175, 55), Increment = 1, ValueName = "回",
    Callback = function(Value) antiBotThreshold = Value end
})
AntiBotTab:AddSlider({
    Name = "判定する秒数",
    Min = 1, Max = 15, Default = 1,
    Color = Color3.fromRGB(212, 175, 55), Increment = 1, ValueName = "秒",
    Callback = function(Value) antiBotTimeWindow = Value end
})
AntiBotTab:AddSlider({
    Name = "再発動までのクールダウン",
    Min = 1, Max = 60, Default = 1,
    Color = Color3.fromRGB(212, 175, 55), Increment = 1, ValueName = "秒",
    Callback = function(Value) antiBotCooldown = Value end
})
AntiBotTab:AddParagraph("対BOT", "同じ人が指定秒以内に指定回数以上チャット、またはBOTワードを含む発言に反応。最優先で発動。")

local MentionTab = Window:MakeTab({ Name = "自分宛て", Icon = "rbxassetid://4483345998", PremiumOnly = false })
MentionTab:AddToggle({
    Name = "自分宛て反応モード (ON/OFF)",
    Default = false,
    Callback = function(Value) autoMentionEnabled = Value end
})
MentionTab:AddDropdown({
    Name = "返す言葉を選択",
    Default = "呼んだ?",
    Options = {"呼んだ?", "呼びましたか?", "どうした", "はい なんでしょうか"},
    Callback = function(Value) mentionSelected = Value end
})
MentionTab:AddParagraph("自分宛て反応", "相手の発言に「みそら」が含まれていたら選択した言葉を返します。")

local LaughTab = Window:MakeTab({ Name = "冷笑BOT😅", Icon = "rbxassetid://4483345998", PremiumOnly = false })
laughToggleWidget = LaughTab:AddToggle({
    Name = "冷笑自動応答 (9キーでも切替可)", Default = false,
    Callback = function(Value) isLaughEnabled = Value if isLaughEnabled then lastChatTime = os.clock() end end
})
LaughTab:AddSlider({
    Name = "みそら様最強って言う確率", Min = 0, Max = 100, Default = 10, Color = Color3.fromRGB(212, 175, 55), Increment = 1, ValueName = "%",
    Callback = function(Value) squadChance = Value / 100 end
})

-- ==========================================
-- チャットイベントの接続
-- ==========================================
local function OnPlayerChatted(senderPlayer, chatText)
    if not senderPlayer or senderPlayer == LocalPlayer then return end

    lastChatTime = os.clock()

    -- ==========================================
    -- 最優先: 対BOT（発動したら他全部スキップ）
    -- ==========================================
    if autoAntiBotEnabled and not isSendingAntiBot then
        if CheckAntiBot(senderPlayer, chatText) then
            task.spawn(function() ExecuteAntiBotSequence(senderPlayer, chatText) end)
            return
        end
    end

    -- ==========================================
    -- 自分宛て反応（他BOTと併用可）
    -- ==========================================
    if autoMentionEnabled and not isSendingMention then
        if chatText:find("みそら", 1, true) or chatText:find("ミソラ", 1, true) then
            task.spawn(function() ExecuteMentionSequence(senderPlayer, chatText) end)
        end
    end

    -- ==========================================
    -- 第2優先: #煽り（発動したら他はスキップ）
    -- ==========================================
    local hasSharp = chatText:find("#", 1, true) or chatText:find("＃", 1, true)
    if autoSharpEnabled and not isSendingSharp and hasSharp then
        task.spawn(function() ExecuteSharpSequence(senderPlayer, chatText) end)
        return
    end

    -- ==========================================
    -- 第3優先: 笑/w/草反応（発動したら他はスキップ）
    -- ==========================================
    if autoLaughReactEnabled and not isSendingLaughReact then
        local warauCount = CountPlain(chatText, "笑")
        local kusaCount = CountPlain(chatText, "草")
        local hasWW = HasConsecutiveW(chatText)

        if warauCount >= 1 then
            task.spawn(function() ExecuteWarauReactSequence(senderPlayer, chatText) end)
            return
        elseif hasWW then
            task.spawn(function() ExecuteWReactSequence(senderPlayer, chatText) end)
            return
        elseif kusaCount >= 1 then
            task.spawn(function() ExecuteKusaReactSequence(senderPlayer, chatText) end)
            return
        end
    end

    -- ==========================================
    -- 第4優先: 67BOT（他BOTと併用可）
    -- ==========================================
    if auto67Enabled and not isSending67 then
        local num = ExtractNumber(chatText)
        if num then
            local formula = MakeFormula(num)
            task.spawn(function() Execute67Sequence(senderPlayer, formula) end)
        end
    end

    -- ==========================================
    -- 第5優先: 通常BOT群（1つだけ発動、上から順）
    -- ==========================================
    if autoStrongReplyEnabled and not isSendingStrongReply then
        task.spawn(function() ExecuteStrongReplySequence(senderPlayer, chatText) end)
    elseif autoOppositeEnabled and not isSendingOpposite then
        task.spawn(function() ExecuteOppositeSequence(senderPlayer, chatText) end)
    elseif autoNekketsuEnabled and not isSendingNekketsu then
        task.spawn(function() ExecuteNekketsuSequence(senderPlayer, chatText) end)
    elseif autoRonpaEnabled and not isSendingRonpa then
        task.spawn(function() ExecuteRonpaSequence(senderPlayer, chatText) end)
    elseif autoHisuEnabled and not isSendingHisu then
        task.spawn(function() ExecuteHisuSequence(senderPlayer, chatText) end)
    elseif autoHiroyukiEnabled and not isSendingHiroyuki then
        task.spawn(function() ExecuteHiroyukiSequence(senderPlayer, chatText) end)
    elseif autoHikakinEnabled and not isSendingHikakin then
        task.spawn(function() ExecuteHikakinSequence(senderPlayer, chatText) end)
    elseif autoHoriEnabled and not isSendingHori then
        task.spawn(function() ExecuteHoriSequence(senderPlayer, chatText) end)
    elseif autoChuunibyouEnabled and not isSendingChuunibyou then
        task.spawn(function() ExecuteChuunibyouSequence(senderPlayer, chatText) end)
    elseif autoOjisanEnabled and not isSendingOjisan then
        task.spawn(function() ExecuteOjisanSequence(senderPlayer, chatText) end)
    elseif autoBurikkoEnabled and not isSendingBurikko then
        task.spawn(function() ExecuteBurikkoSequence(senderPlayer, chatText) end)
    elseif autoHoriReligionEnabled and not isSendingHoriReligion then
        task.spawn(function() ExecuteHoriReligionSequence(senderPlayer, chatText) end)
    elseif autoLyricEnabled and not isSendingLyric then
        task.spawn(function() ExecuteLyricSequence(senderPlayer, chatText) end)
    elseif autoYudanEnabled and not isSendingYudan then
        task.spawn(function() ExecuteYudanSequence(senderPlayer, chatText) end)
    elseif isLaughEnabled then
        task.spawn(function() ExecuteLaughSequence(senderPlayer, chatText) end)
    end
end

pcall(function()
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        TextChatService.MessageReceived:Connect(function(textMessage)
            if textMessage.TextSource then
                local senderPlayer = Players:GetPlayerByUserId(textMessage.TextSource.UserId)
                if senderPlayer then
                    OnPlayerChatted(senderPlayer, textMessage.Text)
                end
            end
        end)
    else
        for _, player in ipairs(Players:GetPlayers()) do
            player.Chatted:Connect(function(msg) OnPlayerChatted(player, msg) end)
        end
        Players.PlayerAdded:Connect(function(player)
            player.Chatted:Connect(function(msg) OnPlayerChatted(player, msg) end)
        end)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Nine then
        isLaughEnabled = not isLaughEnabled
        if laughToggleWidget then laughToggleWidget:Set(isLaughEnabled) end
        showNotification("冷笑モード", isLaughEnabled and "ONになりました 🟢" or "OFFになりました 🔴")
    end
end)

OrionLib:Init()

-- 起動時に「みそら参上！！」を送信
task.spawn(function()
    task.wait(1.5)
    SendChatMessage("みそら参上！！")
end)
