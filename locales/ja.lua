
---@type REC_Core.Locales
return {

    connect = {

        noIdentifier = "\n\n識別子を読み取れませんでした。\nFiveM を再起動してからもう一度お試しください。",
    },

    menu = {

        title = "キャラクター",

        -- %s は職業名、%s は最後に遊んだ日時
        character_description = "%s | 最終プレイ: %s",

        lastPlayed_never = "なし",

        newCharacter = "新しいキャラクター",

        -- %d 使用中のスロット数、%d スロットの総数
        newCharacter_description = "%d / %d スロット使用中",

        play = "プレイ",
        play_description = "このキャラクターでスポーンする",

        delete = "削除",
        delete_description = "このキャラクターを完全に削除する",

        back = "戻る",
    },

    create = {

        title = "新しいキャラクター",

        firstName = "名",
        lastName = "姓",
        birthdate = "生年月日",
        gender = "性別",
        gender_male = "男性",
        gender_female = "女性",
        nationality = "国籍",
    },

    delete = {

        header = "キャラクターの削除",

        -- %s %s はキャラクターの名と姓
        content = "%s %s を削除しますか？ この操作は取り消せません。",

        confirm = "削除する",
        cancel = "やめる",
    },

    notify = {

        title = "RE:CORD",

        -- %s %s はキャラクターの名と姓
        characterCreated = "ようこそ、%s %s さん！",

        characterDeleted = "キャラクターを削除しました。",

        -- %s は金額、%s は口座名
        moneyAdded = "+$%s (%s)",
        moneyRemoved = "-$%s (%s)",

        -- %s は口座名、%s は新しい残高
        moneySet = "%s: $%s",

        -- %s は職業名、%s は階級名
        jobUpdated = "職業: %s / %s",

        -- %s はギャング名、%s は階級名
        gangUpdated = "ギャング: %s / %s",

        dutyOn = "勤務を開始しました。",
        dutyOff = "勤務を終了しました。",

        -- %s は金額
        paycheck = "給料: $%s",
    },

    error = {

        notActive = "このサーバーではコアが有効になっていません。",
        databaseNotReady = "データベースの準備ができていません。スタッフに連絡してください。",
        invalidInput = "入力内容が正しくありません。",
        slotsFull = "キャラクタースロットに空きがありません。",
        notFound = "キャラクターが見つかりません。",
        alreadyLoaded = "そのキャラクターは使用中です。",
        notAllowed = "その操作はできません。",
        busy = "少し待ってからもう一度お試しください。",
        generic = "問題が発生しました。もう一度お試しください。",
    },

    command = {

        noCharacter = "そのプレイヤーはキャラクターを読み込んでいません。",
        unknownJob = "職業または階級が存在しません。",
        unknownGang = "ギャングまたは階級が存在しません。",
        unknownAccount = "口座が存在しません。",
        invalidAmount = "金額は整数で指定してください。",
        failed = "コマンドに失敗しました。",

        -- %s はキャラクター名、%s は職業、%d は階級
        jobSet = "%s の職業を %s (%d) にしました。",

        -- %s はキャラクター名、%s はギャング、%d は階級
        gangSet = "%s のギャングを %s (%d) にしました。",

        -- %s は金額、%s は口座、%s はキャラクター名
        moneyAdded = "%s の %s 口座に $%s を追加しました。",
        moneyRemoved = "%s の %s 口座から $%s を引き出しました。",

        -- %s は口座、%s はキャラクター名、%s は残高
        moneySet = "%s の %s 口座を $%s にしました。",
    },
}
