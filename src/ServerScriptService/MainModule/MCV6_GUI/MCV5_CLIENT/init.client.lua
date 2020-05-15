--[[
	
                   _____           _             __      _______ 
                  / ____|         | |            \ \    / / ____|
  _ __ ___  _   _| |     ___ _ __ | |_ ___ _ __   \ \  / /| |__  
 | '_ ` _ \| | | | |    / _ \ '_ \| __/ _ \ '__|   \ \/ / |___ \ 
 | | | | | | |_| | |___|  __/ | | | ||  __/ |       \  /   ___) |
 |_| |_| |_|\__, |\_____\___|_| |_|\__\___|_|        \/   |____/ 
             __/ |                                               
            |___/        V6 GUI
                                        
	The DarkBright update - Created by Matthew W
	
This is the primary client side game entry point for the myCenter program. This script was created by Matthew W (mwalden.tech).
	
Please do not modify anything below this line, as it is critical for us to give you the next generation application centers. Thank you for entrusting us with your applications!
	^ but feel free to have a go at it, maybe you'll make it better :)
--]]

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
game.Workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable;

repeat success = pcall(function() game.StarterGui:SetCore("ResetButtonCallback", false, function() end) end) wait(0.2) until success
game:GetService("ContextActionService"):BindAction(
    "freezeMovement",
    function()
        return Enum.ContextActionResult.Sink
    end,
    false,
    unpack(Enum.PlayerActions:GetEnumItems())
)
workspace.Camera.CameraType=Enum.CameraType.Scriptable;
game.Players.LocalPlayer:WaitForChild("PlayerGui"):SetTopbarTransparency(0);

--Start

--Global Varibles
local rfunction = game.ReplicatedStorage:WaitForChild("myCenterV6_Function");
local revent = game.ReplicatedStorage:WaitForChild("myCenterV6_Event")
local TweenService = game:GetService("TweenService");
local UserInputService = game:GetService("UserInputService")
local http = game:GetService("HttpService");
local words = require(script.words);

local selected = false;

function tween(thing, properties, time_to_complete)
    local info = TweenInfo.new(time_to_complete, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
    TweenService:Create(thing, info, properties):Play();
end

--GUI Varibles
local gui = script.Parent.BG;
local header = gui.Header;
local abody = gui.AppFrame;
local apps = gui.ApplicationsContainer;
local submit = gui.Submit;
local loading = script.Parent.Loading;

local assets = script.Parent.Assets;
local question_assets = assets.QuestionAssets;
local assets_questions = assets.Questions;

local center = rfunction:InvokeServer("getCenter");
local applications = rfunction:InvokeServer("getApplications").applications;

--[[
DESIGN STUFF
--]]
local config = game.HttpService:JSONDecode(center.Config);
local music = config.Music;
local colorScheme = config.CenterDesign.ColorScheme;
local layoutScheme = colorScheme.layout;
local primaryBTNScheme = colorScheme.primary_btn;

local bgColor = Color3.fromRGB(layoutScheme.bgColor.r,layoutScheme.bgColor.g,layoutScheme.bgColor.b);
local fgColor = Color3.fromRGB(layoutScheme.fgColor.r,layoutScheme.fgColor.g,layoutScheme.fgColor.b);
local txColor = Color3.fromRGB(layoutScheme.txColor.r,layoutScheme.txColor.g,layoutScheme.txColor.b);
local stxColor = Color3.fromRGB(layoutScheme.seTColor.r,layoutScheme.seTColor.g,layoutScheme.seTColor.b);

local btnColor = Color3.fromRGB(primaryBTNScheme.btnColor.r,primaryBTNScheme.btnColor.g,primaryBTNScheme.btnColor.b);
local btnTextColor = Color3.fromRGB(primaryBTNScheme.btnTextColor.r,primaryBTNScheme.btnTextColor.g,primaryBTNScheme.btnTextColor.b);
local hoverBTNcolor = Color3.fromRGB(primaryBTNScheme.btnHoverColor.r,primaryBTNScheme.btnHoverColor.g,primaryBTNScheme.btnHoverColor.b);
local hoverTextBTNcolor = Color3.fromRGB(primaryBTNScheme.btnHoverTextColor.r,primaryBTNScheme.btnHoverTextColor.g,primaryBTNScheme.btnHoverTextColor.b);

gui.ImageColor3 = bgColor;
gui.Header.UIGradient.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0, fgColor),
    ColorSequenceKeypoint.new(0.92, fgColor),
    ColorSequenceKeypoint.new(0.93, bgColor),
    ColorSequenceKeypoint.new(1, bgColor)
});

for a,b in pairs (gui:GetDescendants()) do
    if b.ClassName == "TextLabel" then
        if b:FindFirstChild("Ignore") == false then
            if b:FindFirstChild("Secondary") == false then
                b.TextColor3 = txColor;
            else
                b.TextColor3 = stxColor;
            end
        end
    end
end
for a,b in pairs (assets:GetDescendants()) do
    if b.ClassName == "TextLabel" then
        if b:FindFirstChild("Ignore") == false then
            if b:FindFirstChild("Secondary") == false then
                b.TextColor3 = txColor;
            else
                b.TextColor3 = stxColor
            end
        end
    end
end

gui.loadingFrame.title.TextColor3=stxColor;
gui.loadingFrame.body.TextColor3=stxColor;
gui.pbmc.TextColor3=stxColor;
assets.Questions.SpeedTest.On.TextColor3=fgColor;
gui.Header.CenterName.TextColor3=Color3.new(1-txColor.r, 1-txColor.g, 1-txColor.b);
gui.Header.CenterDescription.TextColor3=Color3.new(1-txColor.r, 1-txColor.g, 1-txColor.b);
local gradident  = ColorSequence.new({
    ColorSequenceKeypoint.new(0, fgColor),
    ColorSequenceKeypoint.new(1, fgColor),
})
assets.AppFrame.AppOutline.UIGradient.Color=gradident;
gui.Submit.AppOutline.UIGradient.Color=gradident;

if center.PartnerPerksEnabled == "Y" then
	gui.pbmc.Text = "Official myCenter Partner"
end

--[[
WHERE THE CODE HAPPENS
--]]

function setupButton(btn)
    btn.bg.ImageColor3 = btnColor;
    btn.sh.ImageColor3 = Color3.new(btnColor.R-0.1, btnColor.G-0.1, btnColor.B-0.1);

    btn.MouseEnter:Connect(function()
        tween(btn.bg, {ImageColor3=hoverBTNcolor}, 0.25)
        tween(btn.sh, {ImageColor3=Color3.new(hoverBTNcolor.R-0.1, hoverBTNcolor.G-0.1, hoverBTNcolor.B-0.1)}, 0.25)
        tween(btn, {TextColor3=hoverTextBTNcolor}, 0.25)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn.bg, {ImageColor3=btnColor}, 0.25)
        tween(btn.sh, {ImageColor3=Color3.new(btnColor.R-0.1, btnColor.G-0.1, btnColor.B-0.1)}, 0.25)
        tween(btn, {TextColor3=btnTextColor}, 0.25)
    end)
end

header.CenterName.Text = center.Name;
header.CenterDescription.Text = center.Description;

for a,b in pairs (applications) do
    local clone = assets.AppFrame:Clone();
    clone.Parent = apps.Container.AppContainers;
    clone.AName.Text = b.Name;
    clone.Description.Text = b.Description;
    clone.Visible = true;


    spawn(function()--stop this from stopiong center from loading, continue in background..
        local userPastAppStatus = rfunction:InvokeServer("getLastApplicationStatus", b["ApiId"]);
        if #userPastAppStatus.responses == 0 then
            clone.AppStatus.Text = "Unapplied";
        else
            local app = userPastAppStatus.responses[1];
            if app.Grade == "" == false then
                clone.AppStatus.Text = app.Result.." / "..app.Grade;
            else
                clone.AppStatus.Text = app.Result;
            end
        end
    end)


    local canApply = rfunction:InvokeServer("canApply", b.ApiId);

    if canApply.can == false then
        clone.ApplyBTN.Text = canApply.reason;
    end

    setupButton(clone.ApplyBTN);
    clone.ApplyBTN.MouseButton1Down:Connect(function()
        if canApply.can then
			if selected == false then
				selected = true;
            	startApplication(b)
			end
        else

            if canApply.can then
                if selected == false then
					selected = true;
	            	startApplication(b)
				end
            else
                --can not apply
                local roblox = canApply.checks.roblox;
                local mycenter = canApply.checks.mycenter;
                local group = canApply.checks.group;
                local Failed = "";
                if roblox == false then
                    Failed="You failed the age check"
                end
                if mycenter == false then
                    Failed="You failed the myCenter check"
                end
                if group == false then
                    Failed="You failed the group check"
                end
                clone.ApplyBTN.Text = canApply.reason;
            end
        end
    end)
end

function startApplication(application_data)
    tween(apps, {Position = UDim2.new(0.164, 0,1, 0)}, 2.5);
    wait(1);
    script.Parent.BG.loadingFrame.Visible=true;
    tween(script.Parent.BG.loadingFrame.title, {TextTransparency = 0}, 0.5);
    tween(script.Parent.BG.loadingFrame.body, {TextTransparency = 0}, 0.5);

    local questions = rfunction:InvokeServer("getQuestions", application_data.ApiId);
    if questions.success then
        questions=questions.questions;

        if #questions == 0 then
            tween(script.Parent.BG.loadingFrame.title, {TextTransparency = 1}, 0.5);
            tween(script.Parent.BG.loadingFrame.body, {TextTransparency = 1}, 0.5);
            wait(0.5);
            script.Parent.BG.loadingFrame.title.Text="This application is unable to be applied for"
            script.Parent.BG.loadingFrame.body.Text="This applicaiton has no questions, if you wish to re-try, please rejoin."
            tween(script.Parent.BG.loadingFrame.title, {TextTransparency = 0}, 0.5);
            tween(script.Parent.BG.loadingFrame.body, {TextTransparency = 0}, 0.5);
        else
            local started = os.time();
            local questionFrames = {};
            local onQuestion = 1;
            local movingDB=false;

            for a,b in pairs (questions) do
                local body = http:JSONDecode(b.question_body);
                if b.question_type == "scaled" or b.question_type == "multiple" then
                    local clone = assets_questions.MultipleChoice:Clone();
                    clone.Name = b["question_id"];
                    clone.Question.Text = b.question;

                    for a,b in pairs (body) do
                        local tclone = question_assets.MultipleChoice:Clone();
                        tclone.Parent = clone.AWRAP.ACON;
                        tclone.Text = b;
                        tclone.Name = a;
                        tclone.Visible = true;
                        setupButton(tclone);

                        tclone.MouseButton1Down:Connect(function()
                            for a,btn in pairs (clone.AWRAP.ACON:GetChildren()) do
                                if btn.ClassName == "TextButton" and btn.Name == tclone == false then
                                    btn.ChoiceSelected.Value = false;
                                    tween(btn.bg, {ImageColor3=btnColor}, 0.25)
                                    tween(btn.sh, {ImageColor3=Color3.new(btnColor.R-0.1, btnColor.G-0.1, btnColor.B-0.1)}, 0.25)
                                    tween(btn, {TextColor3=btnTextColor}, 0.25)
                                end
                            end
                            tclone.ChoiceSelected.Value = true;-- hackyy -- nah
                            tween(tclone.bg, {ImageColor3=btnColor}, 0.25)
                            tween(tclone.sh, {ImageColor3=Color3.new(btnColor.R-0.1, btnColor.G-0.1, btnColor.B-0.1)}, 0.25)
                            tween(tclone, {TextColor3=btnTextColor}, 0.25)
                        end)
                    end
                    clone.Parent = gui.AppFrame.AFRAME;
                    table.insert(questionFrames, {
                        questionData = b,
                        body = body,
                        frame = clone;
                    })
                elseif b.question_type == "text" then
                    local clone = assets_questions.TextResponse:Clone();
                    clone.Name = b["question_id"];
                    clone.Question.Text = b.question;
                    clone.TextBox.PlaceholderText = body[1];
                    clone.Parent = gui.AppFrame.AFRAME;
                    table.insert(questionFrames, {
                        questionData = b,
                        body = body,
                        frame = clone;
                    })
                elseif b.question_type == "speed" then
                    if UserInputService.KeyboardEnabled then
                        local clone = assets_questions.SpeedTest:Clone();
                        clone.Name = b["question_id"];
                        clone.Parent = gui.AppFrame.AFRAME;
                        table.insert(questionFrames, {
                            questionData = b,
                            body = body,
                            frame = clone;
                        })

                        local onChar = 1;
                        local sentence = {};
                        for i=0, math.random(10,15), 1 do
                            local wrd = words[math.random(0,#words)];
                            table.insert(sentence, wrd)
                        end

                        local words = "";
                        for a,b in pairs (sentence) do
                            if a == 1 then
                                local captatalize = string.upper(string.sub(b, 1,1))..string.sub(b,2,string.len(b))
                                words=captatalize;
                            else
                                words=words.." "..b;
                                if a == #sentence then
                                    words=words.."."
                                end
                            end
                        end

                        clone.Typing.Text=words;
                        clone.On.Text="";

                        --Handle adding text.

                        local start = 0;
                        local endTime = 0;

                        UserInputService.InputBegan:Connect(function(input, gameProcessed)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                pcall(function()
                                    local char = string.lower(tostring(string.char(input.KeyCode.Value)));
                                    local charAtPos = string.lower(string.sub(words,onChar, onChar));
                                    if charAtPos == char then
                                        onChar=onChar+1;
                                        clone.On.Text=string.sub(words, 0, onChar-1)
                                        if onChar == 2 then
                                            start=os.time();
                                        elseif onChar == string.len(words)  then
                                            endTime=os.time();
                                            local timeTaken = endTime-start;
                                            local WPM = 60/timeTaken*#sentence;
                                            clone.Time.Value = timeTaken;
                                            clone.WPM.Value = WPM;
                                        end
                                    end
                                end)
                            end
                        end)


                    end
                end
            end

            local function findMultipleChoiceAnswers(frame)
                local selected = {};
                for a,b in pairs (frame.AWRAP.ACON:GetChildren()) do
                    if b.ClassName == "TextButton" then
                        if b.ChoiceSelected.Value == true then
                            table.insert(selected, b.Text);
                        end
                    end
                end
                return selected;
            end

            local function endApplication()
                local activeQuestion = questionFrames[onQuestion].frame;
                tween(activeQuestion, {Position = UDim2.new(-1,0,0,0)}, 0.75);
                tween(gui.AppFrame.NextBTN, {Position = UDim2.new(0.506, 0,1, 0)}, 0.35);
                tween(gui.AppFrame.BackBTN, {Position = UDim2.new(0.044, 0,1, 0)}, 0.35);
                wait(0.75);
                script.Parent.BG.loadingFrame.title.Text = "Please wait while we're putting your application together.";
                script.Parent.BG.loadingFrame.body.Text = "This may take a few seconds.";
                script.Parent.BG.loadingFrame.Visible=true;
                tween(script.Parent.BG.loadingFrame.title, {TextTransparency = 0}, 0.5);
                tween(script.Parent.BG.loadingFrame.body, {TextTransparency = 0}, 0.5);
                wait(0.5) -- because this is fast, and i want it to look semi-smooth

                local processedSelections = {};

                for a,question in pairs (questionFrames) do
                    local answer = "";

                    if question.questionData.question_type == "text" then
                        answer = question.frame.TextBox.Text;
                    elseif question.questionData.question_type == "multiple" or question.questionData.question_type == "scaled" then
                        answer = findMultipleChoiceAnswers(question.frame)[1];
                    elseif question.questionData.question_type == "speed" then
                        answer = {
                            Time = question.frame.Time.Value,
                            WPM = question.frame.WPM.Value
                        }
                    end
                    local data = {
                        question = question.questionData.question,
                        question_id = question.questionData.question_id,
                        question_type = question.questionData.question_type,
                        response = answer
                    };
                    table.insert(processedSelections, data);
                end

                --sending
                wait(0.5) -- because this is fast, and i want it to look semi-smooth
                tween(script.Parent.BG.loadingFrame.title, {TextTransparency = 1}, 0.5);
                tween(script.Parent.BG.loadingFrame.body, {TextTransparency = 1}, 0.5);
                script.Parent.BG.loadingFrame.Visible=false;
                script.Parent.BG.Submit.Visible=true;


                local data = {--All of these values are required, as the server uses them.
                    start = started,
                    finish = os.time(),
                    response = processedSelections,
                    applicationId = application_data.ApiId,
                    RobloxId = game.Players.LocalPlayer.UserId,--hey, by the way.. we do make sure the account exists
                    appVersion = 6.0
                };
	                    local comeback = rfunction:InvokeServer("SubmitApplication", data)
	
	                    if comeback.success == true then
	                        gui.Submit.Header.Text = "Successfully sent your application to our server";
							if comeback.graded == true then
								gui.Submit.Subheader.Text = "We already graded your application -- automatically. You "..comeback.status..", with a "..comeback.grade.."%."
							else
								gui.Submit.Subheader.Text = "We have successfully sent your application! You may now leave."
							end
	                    else
	                       gui.Submit.Header.Text = "Yikes, sorry dude. It didn't go through"
	                       gui.Submit.Subheader.Text = "The servers reasoning, while not valid was: "..comeback.reason
	                    end
            end

            local function completedQuestion(question)
                if question.questionData.question_type == "text" then
                    return question.frame.TextBox.Text == "" == false;
                elseif question.questionData.question_type == "multiple" or question.questionData.question_type == "scaled" then
                    if #findMultipleChoiceAnswers(question.frame) > 0 then
                        return true;
                    end
                elseif question.questionData.question_type == "speed" then
                    return question.frame.Time.Value == 0 == false;
                end
            end

            local function nextQuestion()
                if questionFrames[onQuestion+1] == nil then
                    script.Parent.BG.AppFrame.NextBTN.Text="Submit Application";
                else
                    script.Parent.BG.AppFrame.NextBTN.Text="Next";
                end

                if not movingDB then
                    if questionFrames[onQuestion+1] then
                        --local actualy go to next question
                        if completedQuestion(questionFrames[onQuestion]) then
                            movingDB=true;
                            local activeQuestion = questionFrames[onQuestion].frame;
                            local nextQuestion = questionFrames[onQuestion+1].frame;
                            nextQuestion.Visible = true
                            tween(activeQuestion, {Position = UDim2.new(-1,0,0,0)}, 0.75);
                            tween(nextQuestion, {Position = UDim2.new(0,0,0,0)}, 0.75);
                            wait(0.75);
                            activeQuestion.Visible=false;
                            onQuestion=onQuestion+1;
                            movingDB=false;
                        end
                    else
                        endApplication();

                    end
                end
            end

            local function backQuestion()
                if questionFrames[onQuestion+1] == nil then
                    script.Parent.BG.AppFrame.NextBTN.Text="Submit Application";
                else
                    script.Parent.BG.AppFrame.NextBTN.Text="Next";
                end
                if onQuestion == 1 == false and not movingDB then -- ensure you ain't goin to far back
                    movingDB=true;
                    local activeQuestion = questionFrames[onQuestion].frame;
                    local lastQuestion = questionFrames[onQuestion-1].frame;
                    lastQuestion.Visible = true
                    tween(activeQuestion, {Position = UDim2.new(1,0,0,0)}, 0.75);
                    tween(lastQuestion, {Position = UDim2.new(0,0,0,0)}, 0.75);
                    wait(0.75);
                    activeQuestion.Visible=false;
                    onQuestion=onQuestion-1;
                    movingDB=false;
                end
            end

            setupButton(gui.AppFrame.NextBTN);
            setupButton(gui.AppFrame.BackBTN);
            gui.AppFrame.NextBTN.MouseButton1Click:Connect(nextQuestion)
            gui.AppFrame.BackBTN.MouseButton1Click:Connect(backQuestion)

            --assume loaded

            tween(script.Parent.BG.loadingFrame.title, {TextTransparency = 1}, 0.5);
            tween(script.Parent.BG.loadingFrame.body, {TextTransparency = 1}, 0.5);
            wait(0.5);
            script.Parent.BG.loadingFrame.Visible = false;
            gui.AppFrame.Visible=true;

            --open 1st application

            local first = questionFrames[1].frame;
            first.Visible = true
            tween(first, {Position = UDim2.new(0,0,0,0)}, 0.75);
            --move buttons up
            wait(1.75)
            tween(gui.AppFrame.NextBTN, {Position = UDim2.new(0.506, 0,0.852, 0)}, 0.35);
            tween(gui.AppFrame.BackBTN, {Position = UDim2.new(0.044, 0,0.852, 0)}, 0.35);
        end

    else
        tween(script.Parent.BG.loadingFrame.title, {TextTransparency = 1}, 0.5);
        tween(script.Parent.BG.loadingFrame.body, {TextTransparency = 1}, 0.5);
        wait(0.5);
        script.Parent.BG.loadingFrame.title.Text="Something went wrong fetching the quesitons."
        script.Parent.BG.loadingFrame.title.body="Server said: "..questions.reason
        tween(script.Parent.BG.loadingFrame.title, {TextTransparency = 0}, 0.5);
        tween(script.Parent.BG.loadingFrame.body, {TextTransparency = 0}, 0.5);
    end
end






gui.Visible=true;
tween(script.Parent.Loading.title, {TextTransparency = 1}, 0.5);
tween(script.Parent.Loading.body, {TextTransparency = 1}, 0.5);
wait(0.25)
tween(script.Parent.Loading, {BackgroundTransparency = 1}, 0.5);
wait(0.5)
loading.Visible=false;

--[[
MUSAC
--]]


local nmusic = music;
nmusic=string.gsub(nmusic," ", "");
nmusic=string.split(nmusic,",");

function loop()
    for a,b in pairs(nmusic) do
        script.Sound.SoundId="rbxassetid://"..b;
        script.Sound:Play();
        script.Sound.Ended:Wait();
    end
    loop();
end
loop();
