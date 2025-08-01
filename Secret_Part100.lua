				table.insert(animTable[name].connections, childPart.Changed:connect(function(property) configureAnimationSet(name, fileList) end))\
				animTable[name][idx] = {}\
				animTable[name][idx].anim = childPart\
				local weightObject = childPart:FindFirstChild(\"Weight\")\
				if (weightObject == nil) then\
					animTable[name][idx].weight = 1\
				else\
					animTable[name][idx].weight = weightObject.Value\
				end\
				animTable[name].count = animTable[name].count + 1\
				animTable[name].totalWeight = animTable[name].totalWeight + animTable[name][idx].weight\
	--			print(name .. \" [\" .. idx .. \"] \" .. animTable[name][idx].anim.AnimationId .. \" (\" .. animTable[name][idx].weight .. \")\")\
				idx = idx + 1\
			end\
		end\
	end\
\
	-- fallback to defaults\
	if (animTable[name].count <= 0) then\
		for idx, anim in pairs(fileList) do\
			animTable[name][idx] = {}\
			animTable[name][idx].anim = Instance.new(\"Animation\")\
			animTable[name][idx].anim.Name = name\
			animTable[name][idx].anim.AnimationId = anim.id\
			animTable[name][idx].weight = anim.weight\
			animTable[name].count = animTable[name].count + 1\
			animTable[name].totalWeight = animTable[name].totalWeight + anim.weight\
--			print(name .. \" [\" .. idx .. \"] \" .. anim.id .. \" (\" .. anim.weight .. \")\")\
		end\
	end\
end\
\
-- Setup animation objects\
function scriptChildModified(child)\
	local fileList = animNames[child.Name]\
	if (fileList ~= nil) then\
		configureAnimationSet(child.Name, fileList)\
	end	\
end\
\
script.ChildAdded:connect(scriptChildModified)\
script.ChildRemoved:connect(scriptChildModified)\
\
\
for name, fileList in pairs(animNames) do \
	configureAnimationSet(name, fileList)\
end	\
\
-- ANIMATION\
\
-- declarations\
local toolAnim = \"None\"\
local toolAnimTime = 0\
\
local jumpAnimTime = 0\
local jumpAnimDuration = 0.3\
\
local toolTransitionTime = 0.1\
local fallTransitionTime = 0.3\
local jumpMaxLimbVelocity = 0.75\
\
-- functions\
\
function stopAllAnimations()\
	local oldAnim = currentAnim\
\
	-- return to idle if finishing an emote\
	if (emoteNames[oldAnim] ~= nil and emoteNames[oldAnim] == false) then\
		oldAnim = \"idle\"\
	end\
\
	currentAnim = \"\"\
	currentAnimInstance = nil\
	if (currentAnimKeyframeHandler ~= nil) then\
		currentAnimKeyframeHandler:disconnect()\
	end\
\
	if (currentAnimTrack ~= nil) then\
		currentAnimTrack:Stop()\
		currentAnimTrack:Destroy()\
		currentAnimTrack = nil\
	end\
	return oldAnim\
end\
\
function setAnimationSpeed(speed)\
	if speed ~= currentAnimSpeed then\
		currentAnimSpeed = speed\
		currentAnimTrack:AdjustSpeed(currentAnimSpeed)\
	end\
end\
\
function keyFrameReachedFunc(frameName)\
	if (frameName == \"End\") then\
\
		local repeatAnim = currentAnim\
		-- return to idle if finishing an emote\
		if (emoteNames[repeatAnim] ~= nil and emoteNames[repeatAnim] == false) then\
			repeatAnim = \"idle\"\
		end\
		\
		local animSpeed = currentAnimSpeed\
		playAnimation(repeatAnim, 0.0, Humanoid)\
		setAnimationSpeed(animSpeed)\
	end\
end\
\
-- Preload animations\
function playAnimation(animName, transitionTime, humanoid) \
		\
	local roll = math.random(1, animTable[animName].totalWeight) \
	local origRoll = roll\
	local idx = 1\
	while (roll > animTable[animName][idx].weight) do\
		roll = roll - animTable[animName][idx].weight\
		idx = idx + 1\
	end\
--		print(animName .. \" \" .. idx .. \" [\" .. origRoll .. \"]\")\
	local anim = animTable[animName][idx].anim\
\
	-- switch animation		\
	if (anim ~= currentAnimInstance) then\
		\
		if (currentAnimTrack ~= nil) then\
			currentAnimTrack:Stop(transitionTime)\
			currentAnimTrack:Destroy()\
		end\
\
		currentAnimSpeed = 1.0\
	\
		-- load it to the humanoid; get AnimationTrack\
		currentAnimTrack = humanoid:LoadAnimation(anim)\
		currentAnimTrack.Priority = Enum.AnimationPriority.Core\
		 \
		-- play the animation\
		currentAnimTrack:Play(transitionTime)\
		currentAnim = animName\
		currentAnimInstance = anim\
\
		-- set up keyframe name triggers\
		if (currentAnimKeyframeHandler ~= nil) then\
			currentAnimKeyframeHandler:disconnect()\
		end\
		currentAnimKeyframeHandler = currentAnimTrack.KeyframeReached:connect(keyFrameReachedFunc)\
		\
	end\
\
end\
\
-------------------------------------------------------------------------------------------\
-------------------------------------------------------------------------------------------\
\
local toolAnimName = \"\"\
local toolAnimTrack = nil\
local toolAnimInstance = nil\
local currentToolAnimKeyframeHandler = nil\
\
function toolKeyFrameReachedFunc(frameName)\
	if (frameName == \"End\") then\
--		print(\"Keyframe : \".. frameName)	\
		playToolAnimation(toolAnimName, 0.0, Humanoid)\
	end\
end\
\
\
function playToolAnimation(animName, transitionTime, humanoid, priority)	 \
		\
		local roll = math.random(1, animTable[animName].totalWeight) \
		local origRoll = roll\
		local idx = 1\
		while (roll > animTable[animName][idx].weight) do\
			roll = roll - animTable[animName][idx].weight\
			idx = idx + 1\
		end\
--		print(animName .. \" * \" .. idx .. \" [\" .. origRoll .. \"]\")\
		local anim = animTable[animName][idx].anim\
\
		if (toolAnimInstance ~= anim) then\
			\
			if (toolAnimTrack ~= nil) then\
				toolAnimTrack:Stop()\
				toolAnimTrack:Destroy()\
				transitionTime = 0\
			end\
					\
			-- load it to the humanoid; get AnimationTrack\
			toolAnimTrack = humanoid:LoadAnimation(anim)\
			if priority then\
				toolAnimTrack.Priority = priority\
			end\
			 \
			-- play the animation\
			toolAnimTrack:Play(transitionTime)\
			toolAnimName = animName\
			toolAnimInstance = anim\
\
			currentToolAnimKeyframeHandler = toolAnimTrack.KeyframeReached:connect(toolKeyFrameReachedFunc)\
		end\
end\
\
function stopToolAnimations()\
	local oldAnim = toolAnimName\
\
	if (currentToolAnimKeyframeHandler ~= nil) then\
		currentToolAnimKeyframeHandler:disconnect()\
	end\
\
	toolAnimName = \"\"\
	toolAnimInstance = nil\
	if (toolAnimTrack ~= nil) then\
		toolAnimTrack:Stop()\
		toolAnimTrack:Destroy()\
		toolAnimTrack = nil\
	end\
\
\
	return oldAnim\
end\
\
-------------------------------------------------------------------------------------------\
-------------------------------------------------------------------------------------------\
\
\
function onRunning(speed)\
	if speed > 0.01 then\
		playAnimation(\"walk\", 0.1, Humanoid)\
		if currentAnimInstance and currentAnimInstance.AnimationId == \"http://www.roblox.com/asset/?id=180426354\" then\
			setAnimationSpeed(speed / 14.5)\
		end\
		pose = \"Running\"\
	else\
		if emoteNames[currentAnim] == nil then\
			playAnimation(\"idle\", 0.1, Humanoid)\
			pose = \"Standing\"\
		end\
	end\
end\
\
function onDied()\
	pose = \"Dead\"\
end\
\
function onJumping()\
	playAnimation(\"jump\", 0.1, Humanoid)\
	jumpAnimTime = jumpAnimDuration\
	pose = \"Jumping\"\
end\
\
function onClimbing(speed)\
	playAnimation(\"climb\", 0.1, Humanoid)\
	setAnimationSpeed(speed / 12.0)\
	pose = \"Climbing\"\
end\
\
function onGettingUp()\
	pose = \"GettingUp\"\
end\
\
function onFreeFall()\
	if (jumpAnimTime <= 0) then\
		playAnimation(\"fall\", fallTransitionTime, Humanoid)\
	end\
	pose = \"FreeFall\"\
end\
\
function onFallingDown()\
	pose = \"FallingDown\"\
end\
\
function onSeated()\
	pose = \"Seated\"\
end\
\
function onPlatformStanding()\
	pose = \"PlatformStanding\"\
end\
\
function onSwimming(speed)\
	if speed > 0 then\
		pose = \"Running\"\
	else\
		pose = \"Standing\"\
	end\
end\
\
function getTool()	\
	for _, kid in ipairs(Figure:GetChildren()) do\
		if kid.className == \"Tool\" then return kid end\
	end\
	return nil\
end\
\
function getToolAnim(tool)\
	for _, c in ipairs(tool:GetChildren()) do\
		if c.Name == \"toolanim\" and c.className == \"StringValue\" then\
			return c\
		end\
	end\
	return nil\
end\
\
function animateTool()\
	\
	if (toolAnim == \"None\") then\
		playToolAnimation(\"toolnone\", toolTransitionTime, Humanoid, Enum.AnimationPriority.Idle)\
		return\
	end\
\
	if (toolAnim == \"Slash\") then\
		playToolAnimation(\"toolslash\", 0, Humanoid, Enum.AnimationPriority.Action)\
		return\
	end\
\
	if (toolAnim == \"Lunge\") then\
		playToolAnimation(\"toollunge\", 0, Humanoid, Enum.AnimationPriority.Action)\
		return\
	end\
end\
\
function moveSit()\
	RightShoulder.MaxVelocity = 0.15\
	LeftShoulder.MaxVelocity = 0.15\
	RightShoulder:SetDesiredAngle(3.14 /2)\
	LeftShoulder:SetDesiredAngle(-3.14 /2)\
	RightHip:SetDesiredAngle(3.14 /2)\
	LeftHip:SetDesiredAngle(-3.14 /2)\
end\
\
local lastTick = 0\
\
function move(time)\
	local amplitude = 1\
	local frequency = 1\
  	local deltaTime = time - lastTick\
  	lastTick = time\
\
	local climbFudge = 0\
	local setAngles = false\
\
  	if (jumpAnimTime > 0) then\
  		jumpAnimTime = jumpAnimTime - deltaTime\
  	end\
\
	if (pose == \"FreeFall\" and jumpAnimTime <= 0) then\
		playAnimation(\"fall\", fallTransitionTime, Humanoid)\
	elseif (pose == \"Seated\") then\
		playAnimation(\"sit\", 0.5, Humanoid)\
		return\
