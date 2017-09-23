module("extensions.tongyi", package.seeall)
extension = sgs.Package("tongyi")

do 
 require "lua.config" 
 local config = config
 local kingdoms = config.kingdoms
    table.insert(kingdoms,"jin")
config.color_de = "#DA70D6"
end

simayan = sgs.General(extension,"simayan$","jin","4") 

luatianming = sgs.CreateTriggerSkill{
	name = "luatianming" ,
	events = {sgs.BeforeCardsMove,sgs.StartJudge},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.BeforeCardsMove then
		    if player:getMark("tianming_doing") ~= 0 then return false end 
			local move = data:toMoveOneTime() 
			if move.to and move.to:hasSkill(self:objectName()) and move.to:objectName() == player:objectName() and move.reason.m_reason == sgs.CardMoveReason_S_REASON_DRAW  then 
			   room:setPlayerMark(player,"tianming_doing",1)
         local m_skillName = move.reason.m_skillName
         room:broadcastSkillInvoke("luatianming",1)
          local open_list = sgs.SPlayerList()
          open_list:append(player)
			    local x = move.card_ids:length() 
          local m_ids = move.card_ids 
			    while true do
            if not m_ids:isEmpty() then 
              local c_id = m_ids:first()
              m_ids:removeOne(c_id)
              local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DRAW,player:objectName(), m_skillName,"")
              local card = sgs.Sanguosha:getCard(c_id)
              room:moveCardTo(card,player,sgs.Player_PlaceHand,reason,false)
			    else room:drawCards(player,1, m_skillName)
          end
          local ids 
          if not m_ids:isEmpty() then
            ids = sgs.IntList()
            local d_id = m_ids:first()
            ids:append(d_id)
           else ids = room:getNCards(1)
          end
			      x = x - 1
            
            if (x == 0) then player:setMark("tianming_last",1) end
			      local id = -1
                  room:fillAG(ids,player)
                  id = room:askForAG(player,ids,true,self:objectName())
                  room:clearAG(player)
                  if id ~=-1 and player:getPile("ming"):length() < player:getMaxHp() then 
                        player:addToPile("ming",id,false,open_list)
                        ids:removeOne(id)
                        if not m_ids:isEmpty() then  m_ids:removeOne(id) end
                  end 
                  if not ids:isEmpty() then
			         room:askForGuanxing(player,ids, sgs.Room_GuanxingUpOnly)
		          end
                  if x == 0 then  break end
                end
                room:setPlayerMark(player,"tianming_doing",0)
                player:setMark("tianming_last",0)
                data:setValue(move)
             end
       elseif event == sgs.StartJudge then 
    local judge = data:toJudge()
    local simayan = room:findPlayerBySkillName(self:objectName()) 
    if simayan:getPile("ming"):length() == 0 then return false end 
    if room:askForSkillInvoke(simayan,self:objectName()) then 
        room:broadcastSkillInvoke("luatianming",2)
        simayan:setTag("Judge",data)
        local ming = simayan:getPile("ming")
        room:fillAG(ming,simayan)
        local id = -1
        id = room:askForAG(simayan,ming,true,self:objectName())
        room:clearAG(simayan)
        if id == -1 then return false end
        local card = sgs.Sanguosha:getCard(id)
            room:throwCard(id,simayan)
            judge.card = card
         room:moveCardTo(judge.card,nil,judge.who,sgs.Player_PlaceJudge,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_JUDGE,judge.who:objectName(),self:objectName(),"",judge.reason),true)
          judge:updateResult()
          room:setTag("SkipGameRule",sgs.QVariant(true))
          simayan:removeTag("Judge")
        end
    end
  end,
	can_trigger = function (self,target)
		return target ~= nil
	end
}


luajiquan = sgs.CreateTriggerSkill{
  name = "luajiquan$",
  events = {sgs.DrawNCards},
  on_trigger = function (self,event,player,data)
     local room = player:getRoom()
     local x = data:toInt()
  	 x = x - 1
  	 local simayan = room:findPlayerBySkillName(self:objectName())
  	 if simayan:objectName() == player:objectName() then return false end
     local simayan_data = sgs.QVariant()
     simayan_data:setValue(simayan)
  	 if room:askForSkillInvoke(player,self:objectName(),simayan_data) then 
      room:broadcastSkillInvoke("luajiquan")
  	 	room:drawCards(simayan,1,self:objectName())
      local card = room:askForExchange(simayan,self:objectName(),1,1,true,"@jiquan_give:"..player:objectName())
      player:obtainCard(card)
  	 	data:setValue(x)
  	 end
  end,
  can_trigger = function (self,target)
  	return target:getKingdom() == "jin" 
  end
}

simayan:addSkill(luatianming)
simayan:addSkill(luajiquan)

sgs.LoadTranslationTable{
   ["tongyi"] = "三国统一包",
   ["jin"] = "晋",
   ["ming"] = "命",
   ["simayan"] = "司马炎",
   ["&simayan"] = "司马炎",
   ["#simayan"] = "统一霸业",
   ["luatianming"] = "天命",
   [":luatianming"] = "每次你摸牌时，你可以观看牌堆顶的一张牌，并可以面朝下置于你的武将牌上，称为“命”，“命”的数量不多于你的体力上限；在一名角色的一次判定时，你可以选择一张“命”作为该角色的判定牌。",
   ["luajiquan"] = "集权",
   [":luajiquan"] = "<b>主公技</b>，其他晋势力角色在其摸牌阶段，可以少摸一张牌，并令你摸一张牌，然后你选择你的一张牌交给该角色。",
   ["$luatianming1"] = "知天易，逆天难。",
   ["$luatianming2"] = "吾乃天命之子！",
   ["$luajiquan"] = "有汝辅佐，甚好！",
   ["~simayan"] = "霸业未成，未成啊……",
   ["@jiquan_give"] = "请交给%src一张牌",

}

---------------------------------------------------------------------------------------------------------------------------

quanmou_buff = sgs.CreateTriggerSkill{
  name = "#quanmou_buff",
  events = {sgs.EventPhaseChanging,sgs.Damaged,sgs.Damage},
  on_trigger = function(self,event,player,data) 
    local room = player:getRoom()
    if event == sgs.Damage or event == sgs.Damaged then 
      if not player:hasFlag("quanmou_damage") then  room:setPlayerFlag(player,"quanmou_damage") 
       end 
    elseif event == sgs.EventPhaseChanging then 
    local change = data:toPhaseChange()
       if change.to == sgs.Player_NotActive then 
           room:handleAcquireDetachSkills(player,"-#quanmou_buff")
           if player:hasFlag("quanmou_damage")  then room:setPlayerFlag(player,"-quanmou_damage")  return false end
           for _, sima in sgs.qlist(room:getOtherPlayers(player)) do
             if sima:getMark("ersima") > 0 then 
                room:broadcastSkillInvoke("luaquanmou",2)
               room:damage(sgs.DamageStruct(self:objectName(),sima,player))
           end
         end
       end
     end
    end
}

local Skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("#quanmou_buff") then
Skills:append(quanmou_buff)
end
sgs.Sanguosha:addSkills(Skills)

simashi = sgs.General(extension,"simashi","jin","4",true,true,true)

luaquanmou = sgs.CreateTriggerSkill{
  name = "luaquanmou",
  frequency = sgs.Skill_Compulsory,
  events = {sgs.EventPhaseChanging,sgs.EventPhaseStart},
  on_trigger = function(self,event,player,data)
       local room = player:getRoom()
       if event == sgs.EventPhaseChanging then 
         local change = data:toPhaseChange()
         if (not player:isSkipped(sgs.Player_Play)) and change.to == sgs.Player_Play and player:askForSkillInvoke(self:objectName()) then  
             player:skip(sgs.Player_Play)
             player:setMark(self:objectName(),1)
           end    
        elseif event == sgs.EventPhaseStart then 
        if player:getPhase() == sgs.Player_Finish and (not player:hasFlag("changed")) and player:getMark(self:objectName()) > 0 then
            player:removeMark(self:objectName())
            room:changeHero(player,"simazhao",false,false)
            room:setPlayerFlag(player,"changed")
            local target = room:askForPlayerChosen(player,room:getOtherPlayers(player),"luaquanmou","@quanmou_chose")
            room:broadcastSkillInvoke("luaquanmou",1)
            room:acquireSkill(target,"#quanmou_buff") 
            target:gainAnExtraTurn()
          end
        end
   end,

}

simashi:addSkill(luaquanmou)

simazhao = sgs.General(extension,"simazhao","jin","4",true,true,true)

luazhaoxin = sgs.CreateTriggerSkill{
  name = "luazhaoxin",
  events = {sgs.EventPhaseChanging,sgs.EventPhaseStart},
  on_trigger = function(self,event,player,data) 
     local room = player:getRoom()
     if event == sgs.EventPhaseChanging then 
       local change = data:toPhaseChange()
         if not player:isSkipped(sgs.Player_Judge) then
           if not player:isSkipped(sgs.Player_Draw) then
           if change.to == sgs.Player_Judge and  room:askForSkillInvoke(player,self:objectName())  then
            player:skip(sgs.Player_Judge)
            player:skip(sgs.Player_Draw)
            player:setMark(self:objectName(),1)
        end
      end
    end
    elseif event == sgs.EventPhaseStart then 
      if player:getPhase() == sgs.Player_Finish and (not player:hasFlag("changed")) and player:getMark(self:objectName()) > 0 then 
        player:removeMark(self:objectName())
        room:changeHero(player,"simashi",false,false)
        room:setPlayerFlag(player,"changed")
        if player:getHandcardNum() > 0 then 
        room:broadcastSkillInvoke("luazhaoxin",1)
        room:showAllCards(player)
        local suit_table = {}
        local count = 0
        for _, id in sgs.qlist(player:handCards()) do 
          local suit = sgs.Sanguosha:getCard(id):getSuitString()
          if (not table.contains(suit_table,suit)) then 
             table.insert(suit_table,suit) 
             count = count + 1
           end
         end
         room:drawCards(player,4-count,self:objectName())
       end
       end
     end
  end
}

simazhao:addSkill(luazhaoxin)

ersima = sgs.General(extension,"ersima","jin","4")

change = sgs.CreateTriggerSkill{
  name = "#change",
  frequency = sgs.Skill_Compulsory,
  events = {sgs.GameStart},
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    room:changeHero(player,"simashi",true,true)
    room:setPlayerMark(player,"ersima",1)
  end,
}

ersima:addSkill(change)
ersima:addSkill(luaquanmou)
ersima:addSkill(luazhaoxin)

sgs.LoadTranslationTable{  
   ["ersima"] = "司马师&司马昭",
   ["&ersima"] = "司马师&司马昭",
   ["#ersima"] = "晋之基石", 
   ["luaquanmou"] = "权谋",
   [":luaquanmou"] = "你可以跳过你的出牌阶段，回合结束阶段开始时，将此武将牌倒置，令一名其他角色执行一个额外的回合。若该角色于回合内没有造成或受到伤害，回合结束时，其受到1点你造成的伤害。",
   ["luazhaoxin"] = "昭心",
   [":luazhaoxin"] = "你可以跳过你的判定和摸牌阶段，回合结束阶段开始时，将此武将牌正置，你可以亮出你所有手牌（至少一张），其中每缺少一种花色，你摸一张牌。",
    ["simashi"] = "司马师",--隐藏武将，供二司马用
   ["&simashi"] = "司马师",
   ["#simashi"] = "晋之基石一号",
    ["simazhao"] = "司马昭",--隐藏武将，供二司马用
   ["&simazhao"] = "司马昭",
   ["#simazhao"] = "晋之基石二号",
   ["@quanmou_chose"] = "请选择一名玩家执行一个额外的回合",
   ["$luaquanmou1"] = "心狠手毒，方能成事。",
   ["$luaquanmou2"] = "无用之人，死！",
   ["$luazhaoxin1"] = "哈哈哈哈哈哈……",
}

---------------------------------------------------------------
jiachong = sgs.General(extension,"jiachong","jin","3")

luajinglve = sgs.CreateTriggerSkill{
  name = "luajinglve",
  events = {sgs.CardResponded,sgs.CardUsed},
  on_trigger = function(self,event,player,data)
    local card 
    local room = player:getRoom()
  	if event == sgs.CardResponded then 
  	   card = data:toCardResponse().m_card
  	elseif event == sgs.CardUsed then 
  		card = data:toCardUse().card 
  	end
  	if card:getSuit() == sgs.Card_Diamond then 
  	    local dest = room:askForPlayerChosen(player,room:getOtherPlayers(player),self:objectName(),"Jinglue_chose",true,true)
  	    if not dest then return false end
        dest:setMark("jinglve_target",1)
        room:broadcastSkillInvoke("luajinglve",1)
        local choice 
        if dest:isNude() then choicelist = "draw"
        else choicelist = "draw+discard"
        end
          choice = room:askForChoice(player,self:objectName(),choicelist)
        if choice == "draw" then 
          room:drawCards(dest,1,self:objectName())
        elseif choice == "discard" then 
          room:askForDiscard(dest,self:objectName(),1,1,false,true)
       end
       dest:setMark("jinglve_target",0)
   end
   return false 
   end
}

luabeili = sgs.CreateTriggerSkill{
  name = "luabeili",
  events = {sgs.DamageForseen,sgs.CardsMoveOneTime,sgs.DamageComplete},
  on_trigger =function (self,event,player,data)
    local room = player:getRoom()
    local x = player:getHandcardNum()
    if x < 1 then return false end
    if player:getPhase() ~= sgs.Player_NotActive then return false end
     local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(),self:objectName(),"")
     local dummy = player:wholeHandCards()
    if event == sgs.DamageForseen  then 
       local damage = data:toDamage()
       if room:askForSkillInvoke(player,self:objectName(),data) then 
          room:moveCardTo(dummy,nil,nil,sgs.Player_DiscardPile,reason)
          return true
     end
  	elseif event == sgs.CardsMoveOneTime then 
  	 	local move = data:toMoveOneTime() 
  	 	if move.from and move.from:objectName() == player:objectName() then 
        local m_ids = move.card_ids
        player:setMark("beili_lose",1)
        if room:askForSkillInvoke(player,self:objectName(),data) then 
           room:moveCardTo(dummy,nil,nil,sgs.Player_DiscardPile,reason)
           room:fillAG(m_ids,player)
           local id = room:askForAG(player,m_ids,false,self:objectName())
          room:clearAG(player)
         m_ids:removeOne(id)
  	 	   local card = sgs.Sanguosha:getCard(id)
         local m_ids_table = sgs.QList2Table(m_ids)
         local i = table.indexOf(m_ids_table,id)
  	 	   local from = move.from_places:at(i+1)
  	 	    room:moveCardTo(card,player,from)
         data:setValue(move)
       end
       player:setMark("beili_lose",0)
  	 	end
       elseif event == sgs.DamageComplete then
        local damage = data:toDamage() 
        player:gainMark(tostring(damage.prevented))
    end
  end,
}

jiachong:addSkill(luajinglve)
jiachong:addSkill(luabeili)

sgs.LoadTranslationTable{
 ["jiachong"] = "贾充",
   ["&jiachong"] = "贾充",
   ["#jiachong"] = "胸竖怀奸", 
   ["Jinglue_chose"] = "请选择“经略”的对象",
   ["luajinglve"] = "经略",
   [":luajinglve"] = "每当你使用或打出一张方块牌时，可以令一名其他角色摸一张牌或弃置一张牌",
   ["luabeili"] = "悖礼",
   [":luabeili"] = "回合外，你可以将你所有手牌（至少一张）置入弃牌堆，并选择一项：防止你受到的一次伤害，或将你失去的一张牌返还原位。",
   ["@beili_choice1"] = "你可以弃掉所有手牌防止伤害",
   ["@beili_choice2"] = "你可以弃掉所有手牌收回一张失去的卡", 
 }
----------------------------------------------------------------------------------------------------------------------------------------
xinxianying = sgs.General(extension,"xinxianying","jin","3",false)

dongjianCard = sgs.CreateSkillCard{
   name = "dongjian",
   target_fixed = true,
   on_use = function(self,room,source,targets)
     room:broadcastSkillInvoke("dongjian",1)
     room:drawCards(source,2,"dongjian")
     local card = room:askForExchange(source,"dongjian",2,2,false,"@dongjian_put")
     local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, source:objectName(), self:objectName(), "")
     room:moveCardTo(card,source,nil,sgs.Player_DrawPile,reason)
     local ids = room:getNCards(2)
     room:askForGuanxing(source,ids)
   end
}

dongjian = sgs.CreateViewAsSkill{
   name = "dongjian",
   n = 1,
   view_filter = function (self,selected,to_select)
     return to_select:isRed() and (not to_select:isEquipped()) and #selected < 1 
   end,
   view_as = function(self,cards)
   if #cards == 0 then return nil end
     local vs_card = dongjianCard:clone()
     vs_card:addSubcard(cards[1])
     return vs_card end,
   enabled_at_play = function(self,player)
   	 return not player:hasUsed("#dongjian")
   end
}

zhijie = sgs.CreateTriggerSkill{
   name = "zhijie",
   events = {sgs.CardsMoveOneTime},
   on_trigger = function (self,event,player,data)
   	 local move = data:toMoveOneTime()
   	 local dest = move.from 
   	 if (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD)  
      and dest and dest:getPhase() ~= sgs.Player_Discard and move.to_place == sgs.Player_DiscardPile 
      and dest:objectName() == player:objectName() then 
   	 	local room = player:getRoom()
   	 	local xinxianying = room:findPlayerBySkillName("zhijie") 
     local who = sgs.QVariant()
      who:setValue(player)
        if room:askForSkillInvoke(xinxianying,self:objectName(),who) then 
           room:broadcastSkillInvoke("zhijie",1)
           room:drawCards(player,1,self:objectName())
        end
    end
   end,
   can_trigger = function(self,target)
   	return target ~= nil
   end
}

xinxianying:addSkill(dongjian)
xinxianying:addSkill(zhijie)

sgs.LoadTranslationTable{
   ["xinxianying"] = "辛宪英",
   ["&xinxianying"] = "辛宪英",
   ["#xinxianying"] = "乱世的才女", 
   ["dongjian"] = "洞鉴",
   ["@dongjian_put"] = "请将两张牌置于牌堆顶",
   ["dongjian"] = "洞鉴",
   [":dongjian"] = "出牌阶段，你可以弃置一张红色手牌，然后你摸两张牌，并将两张手牌以任意顺序置于牌堆顶或牌堆底。每阶段限一次。",
   ["zhijie"] = "智解",
   [":zhijie"] = "一名角色的弃牌阶段外，当该角色的牌因弃置而置入弃牌堆时，你可以令其摸一张牌。" ,
   ["$zhijie1"] = "尽在我们掌握之中。",
   ["$dongjian1"] = "嗯~我来想想办法！",

}
------------------------------------------------------------------------------------------------------------------------------------
yanghu = sgs.General(extension,"yanghu","jin","4")

huairouCard = sgs.CreateSkillCard{
  name = "huairou",
  target_fixed = true,
  on_use = function(self,room,source,player)
    local dests = sgs.SPlayerList()
    local list = room:getOtherPlayers(source)
    for _, dest in sgs.qlist(list) do 
      if dest:isWounded() and dest:getCardCount() >= 2 then 
        dests:append(dest)
      end
    end
      local choice_table = {}
      if not dests:isEmpty() then table.insert(choice_table,"recover") end
      if source:getHandcardNum() >= 2 then table.insert(choice_table,"damage") end
      local choice = table.concat(choice_table,"+")
      local result = room:askForChoice(source,"huairou",choice)
      if result == "recover" then 
        room:broadcastSkillInvoke("huairou",1)
        local friend = room:askForPlayerChosen(source,dests,self:objectName())
        local id1 = room:askForCardChosen(source,friend,"he",self:objectName())
        room:throwCard(id1,friend,source)
        local id2 = room:askForCardChosen(source,friend,"he",self:objectName())
        room:throwCard(id2,friend,source)
         local recover = sgs.RecoverStruct()
         recover.recover = 1
         recover.who = source
         room:recover(friend,recover)
      elseif result =="damage" then 
         room:broadcastSkillInvoke("huairou",2)
         room:askForDiscard(source,self:objectName(),2,2,false,false,"@huairou_discard")
         local enemy = room:askForPlayerChosen(source,list,self:objectName())
         local damage = sgs.DamageStruct()
          damage.damage = 1 
          damage.to = enemy
          damage.from = source
          room:damage(damage)
      end
  end
}


huairou = sgs.CreateZeroCardViewAsSkill{
  name = "huairou",
  view_as = function(self) 
    return huairouCard:clone()
  end, 
  enabled_at_play = function(self, player)
  if player:hasUsed("#huairou") then return false end
  local can_invoke = false
  for  _, target in sgs.qlist(player:getAliveSiblings()) do 
    if target:isWounded() then 
      can_invoke = true
      break
    end
  end
    if (player:getHandcardNum() >= 2 or can_invoke) then  
    return true
    else return false
    end
  end, 
}

yanghu:addSkill(huairou)
sgs.LoadTranslationTable{
   ["yanghu"] = "羊祜",
   ["&yanghu"] = "羊祜",
   ["#yanghu"] = "开国元勋", 
   ["huairou"] = "怀柔",
   [":huairou"] = "出牌阶段，你可以选择一项：1、弃置已受伤的一名其他角色两张牌，其回复1点体力。2、弃置两张手牌，对一名其他角色造成1点伤害。每阶段限一次。",
   ["@huairou_discard"] = "请弃两张手牌，发动技能“怀柔”",
   ["damage"] = "造成伤害",
   ["recover"] = "回复生命",
   ["$huairou1"] = "排愁消烦忧，驱害避凶邪！",
   ["$huairou2"] = "此计，伤人于无形！",
}


------------------------------------------------------------------------------------------------------------------------------------------
wenyang = sgs.General(extension,"wenyang","jin","4")

luatuyingCard = sgs.CreateSkillCard{
  name = "luatuying",
  target_fixed = false,
  will_throw = true,
  filter = function(self, targets, to_select)
    if #targets == 0 then
      return sgs.Self:canSlash(to_select, nil, false)
    end
    return false
  end,
  on_use = function(self, room, source, targets)
    local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
    slash:setSkillName(self:objectName())
    local use = sgs.CardUseStruct()
    use.card = slash
    use.from = source
    for _,p in pairs(targets) do
      use.to:append(p)
    end
    local target = use.to:first()
    local dests = sgs.SPlayerList()
    local seat = target:getSeat()
    for _, dest in sgs.qlist(room:getOtherPlayers(target)) do
      if dest:getSeat() == seat + 1 or dest:getSeat() == seat - 1 then 
        dests:append(dest)
      end
    end
    room:useCard(use,true)
    if source:isDead() then return false end
    if source:getMark("tuying_damage") > 0 then 
       source:gainMark("1")
       source:setMark("tuying_damage",0)
       for _, dest in sgs.qlist(dests) do
        if dest:isDead() then dests:removeOne(dest) end
       end
       if dests:isEmpty() then return false end
       local dest = room:askForPlayerChosen(source,dests,self:objectName(),"@tuying_target1",true)
       if not dest then return false end
       local choice = room:askForChoice(dest,self:objectName(),"loseHp+turnOver")
       if choice == "loseHp" then
         room:loseHp(dest)
         elseif choice == "turnOver" then 
          dest:turnOver()
       end
    else 
      dests:append(target)
      for _, dest in sgs.qlist(dests) do
        if dest:isDead() then dests:removeOne(dest) end
        if dest:isNude() then dests:removeOne(dest) end
      end
      if dests:isEmpty() then return false end
      local dest = room:askForPlayerChosen(source,dests,self:objectName(),"@tuying_target2",true)
      if not dest then return false end
      room:broadcastSkillInvoke("luatuying",2)
      local id = room:askForCardChosen(source,dest,"he",self:objectName())
      room:throwCard(id,dest,source)
    end
  end
}

luatuyingVS = sgs.CreateOneCardViewAsSkill{
  name = "luatuying",
  filter_pattern = ".",
  view_as = function(self,originalcard)
    local vs_card = luatuyingCard:clone()
    vs_card:addSubcard(originalcard)
    return vs_card
  end,
  enabled_at_play = function(self,player)
    return false
  end,
  enabled_at_response = function(self, player, pattern)
    return pattern == "@@luatuying"
  end,
}

luatuying = sgs.CreateTriggerSkill{
  name = "luatuying",
  frequency = sgs.Skill_NotFrequent,
  events = {sgs.EventPhaseStart,sgs.DamageCaused},
  view_as_skill = luatuyingVS,
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    if event == sgs.EventPhaseStart then
     if player:getPhase() == sgs.Player_Start then 
        room:askForUseCard(player,"@@luatuying","@luatuying")
       end
    elseif event == sgs.DamageCaused then 
       local damage = data:toDamage()
       if damage.card and damage.card:getSkillName() == self:objectName()  then 
         player:setMark("tuying_damage",1)
      end 
    end
  end,
}
wenyang:addSkill(luatuying)

sgs.LoadTranslationTable{
   ["wenyang"] = "文鸯",
   ["&wenyang"] = "文鸯",
   ["#wenyang"] = "勇冠三军", 
   ["luatuying"] = "突营",
   [":luatuying"] = "准备阶段开始时，你可以弃一张牌，视为对一名角色使用一张杀，若此杀造成伤害，你可以令其相邻的一名角色二选一：失去一点体力；将武将牌翻面。若此杀未造成伤害，你可以弃置其或相邻的一名其他角色一张牌。",
   ["@luatuying"] = "请选择【突营】的对象",
   ["~luatuying"] = "选择一张手牌—>选择一名玩家—>点击确定",
   ["@tuying_target1"] = "请选择一名玩家并使其二选一，失去一点体力或翻面,可以不选",
   ["@tuying_target2"] = "请选择一名玩家并弃置弃一张牌，可以不选",
   ["turnOver"] = "将武将牌翻面",
   ["$luatuying1"] = "策马趋前，斩敌当先!",
 }
----------------------------------------------------------------------------------------------------------------------------
xunxu = sgs.General(extension,"xunxu","jin",3)

luakuixinCard = sgs.CreateSkillCard{
  name = "luakuixin",
  will_throw = false,
  filter = function(self,targets,to_select)
     return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
  end,
  on_use = function(self,room,source,targets)
    local dest = targets[1]
    local room = source:getRoom()
    local can_invoke = false
    local id = self:getSubcards():first()
    local card = sgs.Sanguosha:getCard(id)
    room:showCard(source,id)
    dest:obtainCard(card)
    if card:getHandlingMethod() ~= sgs.Card_MethodUse then 
     can_invoke = true
    else
      local id = card:getEffectiveId()
      local card_use = room:askForUseCard(dest,string.format("%s|.|.|.",tostring(id)),"@kuixinuse")
      if card_use then return false end
    end
    local cards = dest:handCards()
    local left = cards
    local basics = sgs.IntList()
    local non_basics = sgs.IntList()
    for _, card_id in sgs.qlist(cards) do
      local card = sgs.Sanguosha:getCard(card_id)
      if card:getTypeId() == sgs.Card_TypeBasic then
        basics:append(card_id)
      else
        non_basics:append(card_id)
      end
    end
    local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
    local count = 2
    if not basics:isEmpty() then
      repeat
        room:fillAG(left, source, non_basics)
        room:getThread():delay(1000)
        local card_id = room:askForAG(source, basics, true, "luakuixin")
        count = count -1
        basics:removeOne(card_id)
        left:removeOne(card_id)
        dummy:addSubcard(card_id)
        if (count == 0) then
          room:clearAG(source)
          break
        end
        room:clearAG(source)
      until basics:isEmpty()
      if dummy:subcardsLength() > 0 then
        room:throwCard(dummy,dest,source)
      end
      if not (basics:isEmpty()) then
         room:showAllCards(dest,source) 
       end
    end
  end,  
 } 
  luakuixin = sgs.CreateViewAsSkill{ 
  name = "luakuixin",
  n = 1,
  view_filter = function(self,selected,to_select)
     return #selected < 1
  end,
  view_as = function(self,cards) 
    if #cards == 0 then return nil end
    local vs_card = luakuixinCard:clone()
    vs_card:addSubcard(cards[1])
    return vs_card
  end, 
  enabled_at_play = function(self, player)
    return not player:hasUsed("#luakuixin")
  end, 
}


luaanjie = sgs.CreateTriggerSkill{
  name = "luaanjie",
  events = {sgs.TargetConfirming},
  on_trigger = function(self,event,player,data)
     local use = data:toCardUse()
     local room = player:getRoom()
     local dest = use.from
     if dest:objectName() ~= player:objectName() and use.card:getTypeId() ~= sgs.Card_TypeSKill then
      local dest_data = sgs.QVariant()
      dest_data:setValue(dest)
      if room:askForSkillInvoke(player,self:objectName(),dest_data) then 
        room:broadcastSkillInvoke("luaanjie",1)
       local suit = room:askForSuit(player,self:objectName())
       while true do
        if dest:getHandcardNum() == 0 then break end
        local card = dest:getRandomHandCard()
        room:showCard(dest,card:getEffectiveId())
        if card:getSuit() == suit then 
          player:obtainCard(card)
          else break
         end
        end
      end
      end
  end
}


xunxu:addSkill(luakuixin)
xunxu:addSkill(luaanjie)

sgs.LoadTranslationTable{
 ["xunxu"] = "荀勖",
   ["&xunxu"] = "荀勖",
   ["#xunxu"] = "善伺人意",
   ["luakuixin"] = "窥心" ,
   ["luakuixin"] = "窥心",
   [":luakuixin"] = "出牌阶段，你可以展示一张牌并交给一名其他角色，该角色须使用此牌，否则你观看其手牌并弃置其中的两张基本牌。每阶段限一次。",
   ["@kuixinuse"] = "请使用由“窥心”交给你的牌",
   ["luaanjie"] = "暗解",
   [":luaanjie"] = "当其他角色使用的牌选择你为目标时，你可以选择一种花色并展示该角色一张手牌，若与所选花色相同，你获得之，你可以重复此流程，直到花色不相同为止。",
   ["$luakuixin1"] = "攻城为下，攻心为上",
   ["$luaanjie1"] = "明以洞察，哲以保身。",
 }
------------------------------------------------------------------------------------------------------------------------------
duyu = sgs.General(extension,"duyu","jin","3")

luaWuku = sgs.CreateViewAsSkill{
name = "luaWuku",
n = 1,
view_filter = function(self,selected,to_select)
  local wuku = sgs.Self:getPile("wuku")
  local card = sgs.Sanguosha:getCard(wuku:first())
  return to_select:sameColorWith(card) and #selected == 0
  end,
view_as = function(self, cards)
   if #cards == 0 then return nil end  
   local card = cards[1]
   local id = card:getEffectiveId()
   local wuku = sgs.Sanguosha:getCard(sgs.Self:getPile("wuku"):first())
   local name = wuku:objectName()
   local suit = wuku:getSuit()
   local number = wuku:getNumber()
   local scard = sgs.Sanguosha:cloneCard(name,suit,number)
   scard:setSkillName(self:objectName())
   scard:addSubcard(card)
   return scard
   end,
enabled_at_play = function(self, player)
local wuku = player:getPile("wuku")
if wuku:isEmpty() then return false end
local card = sgs.Sanguosha:getCard(wuku:first())
return card:getHandlingMethod() == sgs.Card_MethodUse and  (not card:isKindOf("Jink") )
end,
enabled_at_response = function(self,player,pattern)
local wuku = player:getPile("wuku")
if wuku:isEmpty() then return false end
local card = sgs.Sanguosha:getCard(wuku:first())
return card:match(pattern)
end,
enabled_at_nullification = function(self, player)
local wuku = player:getPile("wuku")
if wuku:isEmpty() then return false end
local card = sgs.Sanguosha:getCard(wuku:first())
return card:isKindOf("Nullification")
end
}

luaWuku_ph = sgs.CreateProhibitSkill{
  name = "#luaWuku_ph",
  is_prohibited = function(self,from,to,card)
      return to:hasSkill("luaWuku") and card:getSkillName() == "luaWuku" 
  end
}



luaWuku_Tr = sgs.CreateTriggerSkill{ 
  name = "#luaWuku_Tr",
  events = {sgs.EventPhaseEnd,sgs.CardEffected},
  on_trigger = function(self,event,player,data)
     local room = player:getRoom()
     if event == sgs.EventPhaseEnd then 
       if (player:getPhase() == sgs.Player_RoundStart or player:getPhase() == sgs.Player_Finish) and room:askForSkillInvoke(player,"luaWuku") 
        then 
        local judge = sgs.JudgeStruct()
        judge.who = player
        judge.pattern =  "DelayedTrick,EquipCard|.|."
        judge.play_animation = false
        judge.negative = true
        judge.good = false
        room:judge(judge)
        local card = judge.card
        if judge:isGood() then 
           local id = card:getEffectiveId()
           local wuku = player:getPile("wuku")
          if not wuku:isEmpty() then room:throwCard(wuku:first(),player,player) end
          player:addToPile("wuku",id)
        end
      end
    elseif event == sgs.CardEffected then 
      local effect = data:toCardEffect()
      local source = effect.from
      local wuku = player:getPile("wuku")
      if wuku:isEmpty() then return false end 
      local thread = room:getThread()
      local card = sgs.Sanguosha:getCard(wuku:first())
      if effect.card:isKindOf("Snatch") then 
        if room:askForSkillInvoke(source,"luaWuku_Discard") then 
           source:obtainCard(card)
           room:setTag("SkipGameRule",sgs.QVariant(true))
           thread:trigger(sgs.CardFinished, room, player, data)
           return true
         end
      elseif effect.card:isKindOf("Dismantlement") then 
        if room:askForSkillInvoke(source,"luaWuku_Discard") then 
           room:throwCard(card,player,source)
           room:setTag("SkipGameRule",sgs.QVariant(true))
           thread:trigger(sgs.CardFinished, room, player, data)
           return true
         end
      end
      end
  end
}

luaPozhu = sgs.CreateTriggerSkill{
  name = "luaPozhu",
  events = {sgs.Damage,sgs.Damaged,sgs.EventPhaseChanging},
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    if event == sgs.Damage or event == sgs.Damaged then 
      if player:getPhase() == sgs.Player_NotActive then return false end
      if not player:hasFlag("pozhu_damage") then 
        room:setPlayerFlag(player,"pozhu_damage")
      end
    else local change = data:toPhaseChange()
      if change.to == sgs.Player_Discard then 
        if player:hasFlag("pozhu_damage") and not player:isSkipped(sgs.Player_Discard) and player:askForSkillInvoke(self:objectName())
            then
            room:setPlayerFlag(player,"pozhu_use") 
            player:skip(sgs.Player_Discard) 
         end
      elseif change.to == sgs.Player_NotActive then 
           if player:hasFlag("pozhu_use") then
              room:setPlayerFlag(player,"-pozhu_use") 
              player:insertPhase(sgs.Player_Play)
              change.to = sgs.Player_Play
              data:setValue(change)
          end
      end
    end
  end
}
extension:insertRelatedSkills("luaWuku","#luaWuku_Tr")
extension:insertRelatedSkills("#luaWuku_Tr","#luaWuku_ph")

duyu:addSkill(luaWuku)
duyu:addSkill(luaWuku_Tr)
duyu:addSkill(luaWuku_ph)
duyu:addSkill(luaPozhu)

sgs.LoadTranslationTable{
   ["duyu"] = "杜预",
   ["&duyu"] = "杜预",
   ["#duyu"] = "左传癖",
   ["luaWuku"] = "武库",
   ["luawuku"] = "武库",
   [":luaWuku"] = "回合开始阶段或结束阶段开始时，你可以进行一次判定，将结果为基本牌或非延时类锦囊牌在游戏外，视为“武库”。武库可被顺手牵羊和过河拆桥作用",
   ["luaPozhu"] = "破竹",
   [":luaPozhu"] = "若在你的回合内，你受到或造成了至少一次伤害，你可以跳过你的弃牌阶段，然后于回合结束时，执行一个额外的出牌阶段。",
   ["wuku"] = "武库",

}
------------------------------------------------------------------------------------------------------------------------------------------
wangyuanji = sgs.General(extension,"wangyuanji","jin","3",false)

luamiaomu = sgs.CreateTriggerSkill{
  name = "luamiaomu",
  events = {sgs.BeforeCardsMove,sgs.CardsMoveOneTime},
  on_trigger = function(self,event,player,data)
    local move = data:toMoveOneTime()
    local room = player:getRoom()
    local source = move.from
    local wangyuanji = room:findPlayerBySkillName("luamiaomu")
    if not wangyuanji then return false end
    if source and source:objectName() == player:objectName() and (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD)
         then
        if event == sgs.BeforeCardsMove then 
        local ids = sgs.IntList()
        local x=move.card_ids:length()
        for i = x-1, 0, -1 do
          ids:append(move.card_ids:at(i))
        end
        local ids_table = sgs.QList2Table(ids)
      wangyuanji:setTag("luamiaomu", sgs.QVariant(table.concat(ids_table, "+")))
       elseif event == sgs.CardsMoveOneTime then 
      local ids_table = wangyuanji:getTag("luamiaomu"):toString():split("+")
      local ids = sgs.IntList()
      for _,id in ipairs(ids_table) do 
        ids:append(tonumber(id))
      end
      local n1 = player:getHandcardNum()
      local handCards = player:handCards()
      local n2 = wangyuanji:getHandcardNum()
      local n = math.min(n1,n2)
      local player_data = sgs.QVariant()
      player_data:setValue(player)
       if n1 > 0 and n2 > 0 and room:askForSkillInvoke(wangyuanji,self:objectName(),player_data) then
         room:broadcastSkillInvoke("luamiaomu",1) 
         local m_ids = sgs.IntList()
         local card_id
         local count = 0
         while count < n do 
          if ids:isEmpty() then break end
          room:fillAG(ids,wangyuanji)
          card_id = -1
          card_id = room:askForAG(wangyuanji,ids,true,"luamiaomu")
          if card_id == -1 then
             room:clearAG(wangyuanji)
              break
          end
          room:clearAG(wangyuanji)
          count = count + 1 
          ids:removeOne(card_id)      
          m_ids:append(card_id)
          end
         local h_ids = sgs.IntList() 
         local x = m_ids:length()
         if wangyuanji:objectName() == player:objectName() then 
           local card = room:askForExchange(player,self:objectName(),x,x,false,"@miaomu_cardchosen"),fa
           h_ids = card:getSubcards()
         else while true do 
           if h_ids:length() == x then break end
           local i = math.random(0,n1-1)
           h_ids:append(handCards:at(i))
           handCards:removeAt(i)
         end
       end
         local exchangeMove = sgs.CardsMoveList()
          local move1 = sgs.CardsMoveStruct(m_ids, player, sgs.Player_PlaceHand,
                                      sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP,"",player:objectName(), "luamiaomu", ""))
         local move2 = sgs.CardsMoveStruct(h_ids,nil, sgs.Player_DiscardPile,
                    sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, player:objectName(),"", "luamiaomu", ""))
          exchangeMove:append(move1)
          exchangeMove:append(move2)
          room:moveCardsAtomic(exchangeMove, false)
          room:askForDiscard(wangyuanji,self:objectName(),x,x,false,false,"@miaomu_discard")
          wangyuanji:removeTag("luamiaomu")
     end
  end
  end
  end,
  can_trigger = function(self, target)
    return target
  end,
  priority = -1,
}

luachijie = sgs.CreateTriggerSkill{
  name = "luachijie",
  events = {sgs.EventPhaseEnd,sgs.EventPhaseStart},
  on_trigger = function(self,event,player,data)
     if player:getPhase() ~= sgs.Player_Discard then return false end
     local room = player:getRoom()
     if event == sgs.EventPhaseStart then 
       if room:askForSkillInvoke(player,self:objectName()) then 
         room:broadcastSkillInvoke("luachijie",1)
         local choice = room:askForChoice(player, self:objectName(), "BasicCard+EquipCard+TrickCard")
         local type_i = choice.."|.|.|hand"
         room:setPlayerCardLimitation(player, "discard", type_i, true)
       end
      elseif event == sgs.EventPhaseEnd then 
        if player:getHandcardNum() > player:getMaxCards() then 
           room:showAllCards(player)
        end
      end
    end
}
wangyuanji:addSkill(luamiaomu)
wangyuanji:addSkill(luachijie)

sgs.LoadTranslationTable{
   ["wangyuanji"] = "王元姬",
   ["&wangyuanji"] = "王元姬",
   ["#wangyuanji"] = "文明皇后", 
   ["luamiaomu"] = "妙目",
   [":luamiaomu"] = "你可以选择其他角色弃置的任意数量的牌替换其等量的手牌，然后你弃置等量的手牌。",
   ["@miaomu_cardchosen"] = "请选择“妙目”交换的手牌",
   ["@miaomu_discard"] = "请支付“妙目”技能的代价",
   ["luachijie"] = "持节",
   [":luachijie"] = "弃牌阶段开始时，你可以选择一种牌的类别，然后你不能弃置此类牌，直到回合结束。",
   ["$luachijie1"] = "持节有度，守节不辱!",
   ["$luamiaomu1"] = "愿尽己力，为君分忧。",
}
------------------------------------------------------------------------------------------------------------------------------------------
wangjun = sgs.General(extension,"wangjun","jin",4)

luaTuijin = sgs.CreateTriggerSkill{
  name = "luaTuijin",
  events = {sgs.Damaged,sgs.Damage},
  on_trigger = function(self,event,player,data)
  local room = player:getRoom()
     local damage = data:toDamage()
     local to = damage.to
     local to_data = sgs.QVariant()
     to_data:setValue(to)
     if player:isKongcheng() then return false end
     if room:askForSkillInvoke(player, self:objectName(), to_data) then
          local x = damage.damage
          local nature = damage.nature
          local list = room:getOtherPlayers(player)
          for _, p in sgs.qlist(list) do
            if p:isKongcheng() then list:removeOne(p)
            end
          end 
          if list:isEmpty() then return false end
          local target = room:askForPlayerChosen(player,list,self:objectName(),"@tuijin-pindian")
          local success = player:pindian(target,"tuijing")
          if success then 
            local targets = room:getOtherPlayers(to)
            local dests = sgs.SPlayerList()
              for _, target in sgs.qlist(targets) do 
                if target:distanceTo(to) == 1 then dests:append(target)
                end
              end
              if dests:isEmpty() then return false end
              local dest = room:askForPlayerChosen(player,dests,self:objectName(),"@tuijin-damage")
              room:damage(sgs.DamageStruct(self:objectName(),player,dest,x,nature))
          end
      end
   end
   }


wangjun:addSkill(luaTuijin)

sgs.LoadTranslationTable{
   ["wangjun"] = "王浚",
   ["&wangjun"] = "王浚",
   ["#wangjun"] = "自矜的将军", 
   ["luaTuijin"] = "推进",
   [":luaTuijin"] = "每当你造成或受到一次伤害后，你可以与一名其他角色拼点，若你赢，你令与受到伤害角色距离为1的另一名角色受到你造成的相同伤害。",
   ["@tuijin-damage"] = "请选择“推进”的伤害对象",
   ["@tuijin-pindian"] = "请选择“推进”的拼点对象",
}
---------------------------------------------------------------------------------------------------------------------------------------
wanghun = sgs.General(extension,"wanghun","jin","4")

Table2IntList = function(theTable)
  local result = sgs.IntList()
  for i = 1, #theTable, 1 do
    result:append(theTable[i])
  end
  return result
end

luaZhijun = sgs.CreateTriggerSkill{
  name = "luaZhijun",
  events = {sgs.SlashEffected,sgs.TargetConfirmed},
  on_trigger = function(self,event,player,data)
     local room = player:getRoom()
     if event == sgs.TargetConfirmed then 
       local use = data:toCardUse()
       local source = use.from
       local dests = sgs.SPlayerList() 
       local wanghun = room:findPlayerBySkillName(self:objectName())
       if not wanghun then return false end
        if source:hasSkill(self:objectName()) then dests = use.to
        elseif use.to:contains(wanghun) then dests:append(wanghun)
        end
        if (not dests:isEmpty()) and use.card:isKindOf("Slash") and dests:first():objectName() == player:objectName() then  
        for _, dest in sgs.qlist(dests) do 
         dest:setMark("luaZhijun",0)
         if room:askForSkillInvoke(wanghun,self:objectName(),data) then 
            local can_invoke = false
            local result = room:askForChoice(dest,self:objectName(),"giveslash+nojink",data)
            if result == "giveslash" then 
              local slash = room:askForCard(dest,"slash","@zhijun-slash:" .. source:objectName(),data,sgs.Card_MethodResponse)
              if slash then dest:addMark("luaZhijun")
              else can_invoke = true
              end
            elseif result == "nojink" then 
              can_invoke = true
            end
            if can_invoke then 
              local jink_table = sgs.QList2Table(source:getTag("Jink_" .. use.card:toString()):toIntList())
              local index = 1
              for _, p in sgs.qlist(use.to) do
                 jink_table[index] = 0
                 index = index + 1
               end
              local jink_data = sgs.QVariant()
              jink_data:setValue(Table2IntList(jink_table))
              source:setTag("Jink_" .. use.card:toString(), jink_data)
              return false
            end
          end
          end
        end
        elseif event == sgs.SlashEffected then 
          if player:getMark("luaZhijun") > 0 then 
            player:removeMark("luaZhijun")
          return true
         end
       end
       return false
  end,
  can_trigger = function(self,target)
     return target:isAlive()
  end
  
}


luaXiacu = sgs.CreateTriggerSkill{
  name = "luaXiacu",
  frequency = sgs.Skill_Compulsory,
  events = {sgs.Damaged,sgs.Damage},
  on_trigger = function(self,event,player,data)
  local room = player:getRoom()
     local from = data:toDamage().from
     local thread = room:getThread()
     local phase = from:getPhase()
     from:setPhase(sgs.Player_Discard)
     room:broadcastProperty(from,"phase")
     thread:trigger(sgs.EventPhaseStart,room,from)
     thread:trigger(sgs.EventPhaseProceeding,room,from)
     thread:trigger(sgs.EventPhaseEnd,room,from)
     from:setPhase(phase)
    room:broadcastProperty(from,"phase")
   end
}
wanghun:addSkill(luaZhijun)
wanghun:addSkill(luaXiacu)
 
sgs.LoadTranslationTable{
  ["wanghun"] = "王浑",
   ["&wanghun"] = "王浑",
   ["#wanghun"] = "灭吴功臣", 
   ["luaZhijun"] = "知军",
   [":luaZhijun"] = "每当你使用（选择目标后）或被使用（成为目标后）【杀】时，你可以令此【杀】的目标选择一项：打出一张【杀】令此【杀】无效，或令此【杀】不能被【闪】响应。",
   ["luaXiacu"] = "狭促",
   [":luaXiacu"] = "<b>锁定技</b>，每当你受到或造成伤一次害后，伤害来源须立即执行一个额外的弃牌阶段。",
   ["giveslash"] = "打出一张【杀】令此【杀】无效",
   ["nojink"] = "令此【杀】不能被【闪】响应",
   ["@zhijun-slash"] = "请打出一张【杀】响应“知军”",
}
--------------------------------------------------------------------------------------------------------------------------------------------
simayou = sgs.General(extension,"simayou","jin","4")

luaRenhuiCard = sgs.CreateSkillCard{
  name = "luaRenhuiCard",
  target_fixed = false,
  will_throw = true,
  filter = function(self,targets,to_select)
     return #targets <= (sgs.Self:getHp() + 1) and to_select:objectName() ~= sgs.Self:objectName()
  end,
  on_use = function(self,room,source,targets)
    local friends = sgs.SPlayerList()
    for _, friend in ipairs(targets) do 
      friends:append(friend)
    end
    room:drawCards(friends,1,"luaRenhui")
    if #targets > source:getHandcardNum() then  room:recover(source,sgs.RecoverStruct(source)) end
  end
}


luaRenhuiVS = sgs.CreateViewAsSkill{
  name = "luaRenhui",
  n = 0,
  view_as = function(self, cards)
    return luaRenhuiCard:clone()
  end,
  enabled_at_play = function(self, player)
    return false
  end,
  enabled_at_response = function(self, player, pattern)
    return pattern == "@@luaRenhui"
  end
}


luaRenhui = sgs.CreateTriggerSkill{
  name = "luaRenhui",
  frequency = sgs.Skill_NotFrequent,
  events = {sgs.EventPhaseChanging},
  view_as_skill = luaRenhuiVS,
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    local change = data:toPhaseChange()
    if player:isSkipped(sgs.Player_Draw) then return false end
    local nextphase = change.to
    if nextphase == sgs.Player_Draw then
      if room:askForUseCard(player, "@@luaRenhui", "@luaRenhui") then
        player:skip(sgs.Player_Draw)
      end
  end
end
}


simayou:addSkill(luaRenhui)

sgs.LoadTranslationTable{
  ["simayou"] = "司马攸",
   ["&simayou"] = "司马攸",
   ["#simayou"] = "盛名的贤王", 
   ["luarenhui"] = "仁惠",
   ["luaRenhui"] = "仁惠",
   [":luaRenhui"] = "你可以跳过摸牌阶段，令至多X名其他角色各摸一张牌（X为你当前已损失的体力值+1），若总计摸牌数多于你的手牌数量，你回复1点体力。",
   ["@luaRenhui"] = "请选择“仁惠”的对象",
   ["~luaRenhui"] = "依次点选对象",
 }
 --------------------------------------------------------------------------------------------------------------------------------------
jikang = sgs.General(extension,"jikang","jin","3")

luaFengyi = sgs.CreateTriggerSkill{
  name = "luaFengyi",
  events = {sgs.EventPhaseStart,sgs.FinishJudge,sgs.EventPhaseEnd},
  on_trigger = function(self,event,player,data)
  local room = player:getRoom()
  local jikang = room:findPlayerBySkillName("luaFengyi")
  if event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Judge then 
    local cards = player:getJudgingArea()
    local judging_ids = {}
    for _,card in sgs.qlist(cards) do 
      local id = card:getEffectiveId()
      table.insert(judging_ids,id)
    end
    local judging_ids_string = table.concat(judging_ids,":")
    jikang:setTag("judging_card",sgs.QVariant(judging_ids_string))
  elseif event == sgs.FinishJudge then 
  local judge = data:toJudge()
  local judging_ids = jikang:getTag("judging_card"):toString():split(":")
  if #judging_ids == 0 then return false end
  local id = -1
  local card 
  for _, Jid in ipairs(judging_ids) do 
     local card = sgs.Sanguosha:getCard(Jid)
      if card:objectName() == judge.reason then 
       id = Jid
       table.removeAll(judging_ids,id)
       break
     end
   end
   if id == -1 then return false end
  jikang:setTag("judging_card",sgs.QVariant(table.concat(judging_ids,":")))
  local card = sgs.Sanguosha:getCard(id)
   local msg = sgs.LogMessage()
    msg.from = player
    msg.type = "#judging"
    msg.card_str = card:getEffectiveId()
    room:sendLog(msg)
     local suit_string = card:getSuitString()
     local number_string = card:getNumberString()
     local name = card:objectName()
     local pattern = string.format(".|%s|%s|hand",suit_string,number_string)
     local player_list = room:getOtherPlayers(player)
      room:sortByActionOrder(player_list)
      local target = player_list:last()
      local choicelist_table = {}
     for _, card in sgs.qlist(jikang:getHandcards()) do
        if card:getSuitString() == suit_string and card:getNumberString() == number_string 
          then table.insert(choicelist_table,"takecard")
          break 
        end
      end
      if not target:containsTrick(card:objectName()) then table.insert(choicelist_table,"movefront") end
      local choicelist = table.concat(choicelist_table,"+")
      if choicelisr == "" then return false end
  if room:askForSkillInvoke(jikang,self:objectName(),data) then 
     local choice = room:askForChoice(jikang,self:objectName(),choicelist,data)
     if choice == "movefront" then 
       local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER,player:objectName(),target:objectName(),self:objectName(),"")
       room:moveCardTo(card,player,target,sgs.Player_PlaceDelayedTrick,reason)
     elseif choice == "takecard" then 
      local suit = card:getSuit()
      local number = card:getNumber()
      local Ncard = room:askForCard(jikang,pattern,"@fengyi-card")
      if not Ncard then return false end
      local takecard = sgs.Sanguosha:cloneCard(name,suit,number)
      takecard:addSubcard(Ncard)
      takecard:setSkillName(self:objectName())
      room:moveCardTo(takecard,player,sgs.Player_PlaceJudge,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP,jikang:objectName(),player:objectName(),"luaFengyi", ""))
      room:moveCardTo(card,jikang,sgs.Player_PlaceHand,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP,player:objectName(),jikang:objectName(),"luaFengyi", ""))
    end
    end
  elseif event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Judge then 
    jikang:removeTag("judging_card")
  end
  end,
  can_trigger = function(self,target)
    return target ~= nil
  end
}

luayinlv = sgs.CreateTriggerSkill{
  name = "luayinlv",
  events = {sgs.Damaged,sgs.HpRecover},
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    local list = room:getOtherPlayers(player)
    if event == sgs.Damaged then 
    local x = -(data:toDamage().damage)
       if room:askForSkillInvoke(player,self:objectName(),sgs.QVariant(x)) then 
          room:broadcastSkillInvoke("luayinlv",1)
          for _, dest in sgs.qlist(list) do 
            room:damage(sgs.DamageStruct(self:objectName(),nil,dest))
          end
        end
     elseif event == sgs.HpRecover then 
     local x = data:toRecover().recover
       if player:getHp() <= 1 then return false end
       if room:askForSkillInvoke(player,self:objectName(),sgs.QVariant(x)) then
         room:broadcastSkillInvoke("luayinlv",1)
         for _, dest in sgs.qlist(list) do 
            room:recover(dest,sgs.RecoverStruct())
          end
        end
      end
  end
}

jikang:addSkill(luayinlv)
jikang:addSkill(luaFengyi)

sgs.LoadTranslationTable{
   ["jikang"] = "嵇康",
   ["&jikang"] = "嵇康",
   ["#jikang"] = "广陵绝响", 
   ["luaFengyi"] = "风仪",
   [":luaFengyi"] = "在一名角色判定区里的一张牌判定生效时，你可以将之移动至该角色上家的判定区里，或用一张花色和点数都相同的手牌替换之。",
   ["luayinlv"] = "音律",
   [":luayinlv"] = "每当你受到一次伤害后，你可以令所有其他角色各受到1点伤害；每当你回复一次体力后，你可以令所有其他角色各回复1点体力。",
   ["movefront"] = "将判定牌移动至该角色上家的判定区里",
   ["takecard"] = "用一张花色和点数都相同的手牌判定牌",
   ["@fengyi-card"] = "请打出一张与正在判定的延时锦囊花色和点数都相同的手牌",
   ["#judging"] = "%from的%card判定生效",
   ["$luayinlv1"] = "（抚琴声~）",
   ["$luayinlv2"] = "（抚琴声~）",
}
----------------------------------------------------------------------------------------------------------------------------------------
wangrong = sgs.General(extension,"wangrong","jin","3")

luaXiuche = sgs.CreateTriggerSkill{
  name = "luaXiuche",
  frequency = sgs.Skill_Frequent,
  events = {sgs.CardsMoveOneTime,sgs.EventPhaseEnd},
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    if player:getPhase() == sgs.Player_Discard then 
      if event == sgs.CardsMoveOneTime   then
         local move = data:toMoveOneTime()
         local source = move.from
        if source and source:objectName() == player:objectName() 
          and (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD) then 
         local count = 0
         for _, id in sgs.qlist(move.card_ids) do 
            if sgs.Sanguosha:getCard(id):isRed() then count = count + 1 
            end
          end
          room:setPlayerMark(player,self:objectName(), player:getMark(self:objectName()) + count)
        end
     elseif event == sgs.EventPhaseEnd then 
       local x = player:getMark(self:objectName())
       if x == 0 then return false end 
       player:drawCards(x,self:objectName())
       room:setPlayerMark(player,self:objectName(),0)
     end
   end
 end
}

luaPinjian = sgs.CreateTriggerSkill{
  name = "luaPinjian",
  events = {sgs.PreHpRecover,sgs.PreHpLost,sgs.PreDamageDone},
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    local wangrong = room:findPlayerBySkillName("luaPinjian")
    if not wangrong then return false end
    local x
    if event == sgs.PreDamageDone then 
      x = -(data:toDamage().damage) 
    elseif event == sgs.PreHpLost() then 
      x = -(data:toInt())
    elseif event == sgs.PreHpRecover then 
     x = data:toRecover().recover
    end
    local prompt_list = {
    "@pinjian-discard",
    player:objectName(),
    tostring(x)
  }
    prompt = table.concat(prompt_list,":")
    if room:askForDiscard(wangrong,self:objectName(),1,1,true,false,prompt) then 
        local judge = sgs.JudgeStruct()
        judge.who = player
        judge.pattern =  ".|red|."
        judge.play_animation = true
        judge.negative = false
        judge.good = true
        room:judge(judge)
        if judge:isGood() then 
          room:setTag("SkipGameRule",sgs.QVariant(true))
          return true
        end
      end
  end,
  can_trigger = function(self,target)
    return target:getHp() == 1
  end
}


wangrong:addSkill(luaXiuche)
wangrong:addSkill(luaPinjian)

sgs.LoadTranslationTable{
   ["wangrong"] = "王戎",
   ["&wangrong"] = "王戎",
   ["#wangrong"] = "双目如电", 
   ["luaXiuche"] = "秀彻",
   [":luaXiuche"] = "弃牌阶段内，若你弃置了一张或更多红色牌，弃牌阶段结束时，你摸等量的牌。",
   ["luaPinjian"] = "品鉴",
   [":luaPinjian"] = "每当一名体力为1的角色体力变化时，你可以弃置一张手牌，并进行一次判定，若结果为红，防止其体力发生变化。" ,
   ["@pinjian-discard"] = "你可舍弃一张手牌使用“品鉴”技能",
 }
------------------------------------------------------------------------------------------------------------------------------------------
zhouzhi = sgs.General(extension,"zhouzhi","jin","4")

luaJixi = sgs.CreateTriggerSkill{
  name = "luaJixi",
  events = {sgs.EventPhaseChanging},
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    local change = data:toPhaseChange()
    if change.to == sgs.Player_Discard then 
       if player:isSkipped(sgs.Player_Discard) then return false end
       if room:askForSkillInvoke(player,self:objectName()) then 
         local target = room:askForPlayerChosen(player,room:getOtherPlayers(player),self:objectName(),"@jixi-Pchose")
         local phaselist = sgs.PhaseList()
         phaselist:append(sgs.Player_Discard)
         local x = target:getMaxCards()
         local n = player:getHandcardNum()
         local p_handCards = player:handCards()
         local t_handCards = target:handCards()
         target:addToPile("juwai",t_handCards,false)
         local dummy = sgs.Sanguosha:cloneCard("slash",sgs.Card_NoSuit,0)
         while n > x do 
           local i = math.random(0,n-1)
           local id = p_handCards:at(i)
           dummy:addSubcard(id)
           p_handCards:removeAt(i)
           n = n - 1
         end
         local dummy_subcards = dummy:getSubcards()
         if dummy ~= nil then 
         local number = dummy:getSubcards():length() 
         room:moveCardTo(dummy,player,target,sgs.Player_PlaceHand,sgs.CardMoveReason())
       end
         room:setPlayerMark(target,"jixi-DPhase",1)
         target:play(phaselist)
         room:setPlayerMark(target,"jixi-DPhase",0)
         if x ~= 0 then  
         local ids = target:getPile("juwai")
         local move = sgs.CardsMoveStruct(ids,target,sgs.Player_PlaceHand,
                                      sgs.CardMoveReason())
         room:moveCardsAtomic(move,false)
       end
         for _, id in sgs.qlist(dummy:getSubcards()) do 
            local card = sgs.Sanguosha:getCard(id)
            if card:getTypeId() == sgs.Card_TypeTrick then 
              room:damage(sgs.DamageStruct(self:objectName(),player,target))
            end
          end
         player:skip(sgs.Player_Discard)
      end
    end
  end
}

luaJixi_buff = sgs.CreateMaxCardsSkill{
  name = "#luaJixi_buff",
  fixed_func = function(self, target)
      local hp = target:getHp()
      local x = sgs.Sanguosha:correctMaxCards(target) 
    if target:getMark("jixi-DPhase") > 0 then
        return -x
    else 
       return hp
    end
  end
}
extension:insertRelatedSkills("luaJixi","#luaJixi_buff")

zhouzhi:addSkill(luaJixi)
zhouzhi:addSkill(luaJixi_buff)

sgs.LoadTranslationTable{
  ["zhouzhi"] = "周旨",
   ["&zhouzhi"] = "周旨",
   ["#zhouzhi"] = "以计代战", 
   ["luaJixi"] = "计袭",
   [":luaJixi"] = "你可以跳过你的弃牌阶段,随机舍弃手牌至一名其他角色手牌上限，弃置手牌视为该角色额外弃牌阶段所弃，若该角色于此阶段内每弃置一张锦囊牌，弃牌阶段结算时，其便受到1点你造成的伤害。",
   ["juwai"] = "游戏外的牌",
   ["@jixi-Pchose"] = "请选择“计袭”的对象。",
}
-----------------------------------------------------------------------------------------------------------
local use_god_simayi = 0 -- 武将使用开关，0为不使用该武将，1为使用

if use_god_simayi == 1 then 
Ngod_simayi = sgs.General(extension,"Ngod_simayi","god","3")

luaDaishi = sgs.CreateTriggerSkill{--
  name = "luaDaishi",
  frequency = sgs.Skill_Compulsory,
  events = {sgs.TargetConfirming,sgs.ChoiceMade},
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    local god_simayi = room:findPlayerBySkillName("luaDaishi")
    if event == sgs.TargetConfirming then 
      local use = data:toCardUse()
      if use.card:isKindOf("EquipCard") then return false end
      if use.to:contains(god_simayi) and use.from ~= god_simayi then 
      if player:objectName() ~= god_simayi:objectName() then return false end 
        use.to:removeOne(god_simayi)
        god_simayi:gainMark("@shi")
       if use.card:isKindOf("SkillCard") then return false end  --此句删去后“待势”对司马懿成为目标的技能卡有效，但有部分bug，可能强退。
        data:setValue(use)
      elseif use.from == god_simayi then 
        use.to:removeOne(player)
        if god_simayi:getMark("daishi_counted") == 0 then 
          room:setPlayerMark(god_simayi,"daishi_counted",1) 
          god_simayi:gainMark("@shi")
        end
        if use.to:isEmpty() then  room:setPlayerMark(god_simayi,"daishi_counted",0) end
        data:setValue(use)
      end
      elseif event == sgs.ChoiceMade then --被指定为非技能卡技能对象是，加标记，但不无效技能。
        local list = data:toString():split(":")
        if list[1] == "playerChosen" and list[3] == god_simayi:objectName() then 
          god_simayi:gainMark("@shi")
        end
        end
  end,
  can_trigger = function(self,target)
     return target ~= nil
  end
}

Ngod_simayi:addSkill(luaDaishi)


luaJieshiCard = sgs.CreateSkillCard{
  name = "luaJieshi",
  will_throw = true,
  filter = function(self,targets,to_select)
    return #targets < 1 and (not to_select:isAllNude())
  end,
  on_effect = function(self,effect)
    local source = effect.from 
    source:gainMark("@shi")
    local target = effect.to
    local room = source:getRoom()
    local choice_table = {}
    if not target:isKongcheng() then  table.insert(choice_table,"h") end
    if (not target:getEquips():isEmpty()) then   table.insert(choice_table,"e") end
    if (not target:getJudgingArea():isEmpty()) then table.insert(choice_table,"j") end
    local choicelist = table.concat(choice_table, "+")
    local result = room:askForChoice(source,"luaJieshi",choicelist)
    local x 
    if result == "h" then 
      x = target:getHandcardNum() 
    elseif result == "e" then 
      x = target:getEquips():length()
    elseif result == "j" then 
      x = target:getJudgingArea():length()
    end
    local dummy = sgs.Sanguosha:cloneCard("slash",sgs.Card_NoSuit,0)
    local mhp = target:getMaxHp()
    local handCards = target:handCards()
    local count = 0
      while  true do 
        local id 
        if result == "h" then 
          local i = math.random(0,x-count-1)
          id = handCards:at(i)
          handCards:removeAt(i)
        else 
         id = room:askForCardChosen(source,target,result,"luaJieshi",false,sgs.Card_MethodNone,dummy:getSubcards())
      end
        dummy:addSubcard(id)
        count = count + 1
        source:addMark("jieshi_draw")
        if (count == x or count == mhp) then break end
        local choice = room:askForChoice(source,string.format("haveChosen%s",count),"yes+no")
        if choice == "no" then break end
     end
     if dummy ~= nil then 
     room:moveCardTo(dummy,target,nil,sgs.Player_DrawPile,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT,target:objectName()))
     local ids = room:getNCards(count)
     room:askForGuanxing(source,ids, sgs.Room_GuanxingUpOnly)
   end
   end
   }
luaJieshi = sgs.CreateOneCardViewAsSkill{
  name = "luaJieshi",
  filter_pattern = "BasicCard|.|.",
  view_as = function(self, originalCard)
    local skillcard = luaJieshiCard:clone()
    skillcard:addSubcard(originalCard)
    return skillcard
  end,
  enabled_at_play = function(self,player)
    return not player:hasUsed("#luaJieshi")
  end, 
}

luaJieshi_tr = sgs.CreateTriggerSkill{
  name = "#luaJieshi_tr",
  events = {sgs.EventPhaseChanging},
  on_trigger = function(self,event,player,data)
    local change = data:toPhaseChange()
    if change.to == sgs.Player_NotActive  then 
      local room = player:getRoom()
      local x = player:getMark("jieshi_draw")
      player:drawCards(x,"luaJieshi")
      room:setPlayerMark(player,"jieshi_draw",0)
  end   
end
}
Ngod_simayi:addSkill(luaJieshi) 
Ngod_simayi:addSkill(luaJieshi_tr)
extension:insertRelatedSkills("luaJieshi","#luaJieshi_tr")

luaShicheng = sgs.CreateTriggerSkill{
  name = "luaShicheng",
  events = {sgs.EventPhaseChanging},
  on_trigger = function(self, event, player, data)
    local change = data:toPhaseChange()
    if change.to == sgs.Player_Discard then
       local room = player:getRoom()
      if not player:isSkipped(sgs.Player_Discard) and player:getMark("@shi") >= 2 then
        if player:askForSkillInvoke(self:objectName()) then
          player:loseMark("@shi",2)
          local result = room:askForChoice(player,self:objectName(),"draw+play")
          if result == "draw" then 
          change.to = sgs.Player_Draw
          elseif result == "play" then 
            change.to = sgs.Player_Play
          end
          data:setValue(change)
        end
      end
    else
      return false
    end
    return false
  end
}

local Skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("luaShicheng") then
Skills:append(luaShicheng)
end
sgs.Sanguosha:addSkills(Skills)

luaZaoshi = sgs.CreateTriggerSkill{
  name = "luaZaoshi" ,
  events = {sgs.EventPhaseStart} ,
  frequency = sgs.Skill_Wake ,
  on_trigger = function(self, event, player, data)
       player:setMark("luaZaoshi", 1)
       local room = player:getRoom()
       player:gainMark("@waked")
       room:detachSkillFromPlayer(player,"luaDaishi")
       room:acquireSkill(player, "luaShicheng")
       room:doLightbox("$zaoshi")
    return false
  end ,
  can_trigger = function(self, target)
    return target and target:isAlive() and target:hasSkill(self:objectName())
        and (target:getPhase() == sgs.Player_RoundStart)
        and (target:getMark("luaZaoshi") == 0)
        and (target:getMark("@waked") == 0)
        and (target:getMark("@shi") >= 4)
  end
}
Ngod_simayi:addSkill(luaZaoshi)

sgs.LoadTranslationTable{
   ["Ngod_simayi"] = "神司马懿",
   ["&Ngod_simayi"] = "神司马懿",
   ["#Ngod_simayi"] = "晋宣帝", 
   ["@shi"] = "势标记",
   ["luaDaishi"] = "待势",
   [":luaDaishi"] = "<b>锁定技</b>，当你成为其他角色选择的目标时或其他角色成为你选择的目标时，取消之，并获得一枚势标记。",
   ["luaJieshi"] = "借势",
   ["luejieshi"] = "借势",
   [":luaJieshi"] = "出牌阶段，你可以弃置一张基本牌并获得1枚势标记，将一名角色一个区域里不多于其体力上限数量的牌以任意顺序置于牌堆顶，然后你的回合结束时其摸等量的牌。每阶段限一次。",
   ["luojieshi"] = "借势",
   ["haveChosen"] = "已选卡牌数",
   ["h"] = "手牌区",
   ["e"] = "装备区",
   ["j"] = "判定区",
   ["yes"] = "继续选择",
   ["no"] = "不继续选择",
   ["luaZaoshi"] = "造势",
   [":luaZaoshi"] = "<b>觉醒技</b>，回合开始阶段开始时，若你获得4枚或更多的势标记时，你失去技能“假痴”，并获得技能“势成”。",
   ["luaShicheng"] = "势成",
   [":luaShicheng"] = "你可以弃置2枚势标记，将你的弃牌阶段当摸牌阶段或出牌阶段执行。",
   ["$zaoshi"] = "大势已成，万事可为也",
 }
end
-----------------------------------------------------------------------------------------------------------------------------------------
Jzhonghui = sgs.General(extension,"Jzhonghui","jin","4")

luaBinglveCard = sgs.CreateSkillCard{
  name = "luaBinglveCard",
  will_throw = true,
  filter = function(self,targets,to_select)
    return to_select:getJudgingArea():isEmpty() and #targets < 1
  end,
  on_validate = function(self,cardUse)
    local id = self:getSubcards():first()
    local card = sgs.Sanguosha:getCard(id)
    local dest = cardUse.to:at(0)
    if cardUse.from:objectName() == dest:objectName() then 
      dest:drawCards(2,"luaBinglve")
    end
    local suit = card:getSuit()
    local number = card:getNumber()
    local delayedTrick
    if card:isRed() then 
     delayedTrick = sgs.Sanguosha:cloneCard("indulgence",suit,number)
  else delayedTrick = sgs.Sanguosha:cloneCard("supply_shortage",suit,number)
  end
    delayedTrick:addSubcard(self)
    return delayedTrick
  end
}


luaBinglveVS = sgs.CreateOneCardViewAsSkill{
  name = "luaBinglve",
  filter_pattern = "BasicCard|spade,diamond,club",
  view_as = function(self,originalCard)
    local vs_card = luaBinglveCard:clone()
    vs_card:addSubcard(originalCard)
    return vs_card
  end,
  enabled_at_play = function(self,player)
    return false
  end,
  enabled_at_response = function(self,player,pattern)
    return pattern == "@@luaBinglve"
  end
}
luaBinglve = sgs.CreateTriggerSkill{
  name = "luaBinglve",
  events = {sgs.GameStart,sgs.EventPhaseStart},
  view_as_skill = luaBinglveVS,
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    if event == sgs.GameStart then 
       room:loseHp(player)
    elseif event == sgs.EventPhaseStart then 
      if player:getPhase() == sgs.Player_Discard then 
        room:askForUseCard(player,"@@luaBinglve","@luaBinglve")
    end
  end
end
}
Jzhonghui:addSkill(luaBinglve)


luaZizhong = sgs.CreateMaxCardsSkill{
   name = "luaZizhong",
   extra_func = function(self,target)
     if target:hasSkill(self:objectName()) then
        local n1 = target:getEquips():length()
        local n2 = target:getJudgingArea():length()
        return n1 + n2
      end 
   end
 }

 luaZizhong_ds = sgs.CreateDistanceSkill{
   name = "#luaZizhong_ds",
   correct_func = function(self,from,to)
     if to:hasSkill(self:objectName()) and (not to:getJudgingArea():isEmpty()) then 
       return 1
   end
 end
}

extension:insertRelatedSkills("luaZizhong","#luaZizhong_ds")
Jzhonghui:addSkill(luaZizhong)
Jzhonghui:addSkill(luaZizhong_ds)

sgs.LoadTranslationTable{
  ["Jzhonghui"] = "钟会",
  ["&Jzhonghui"] = "钟会",
  ["#Jzhonghui"] = "谋谟自图",
  ["luaBinglve"] = "兵略",
  [":luaBinglve"] = "弃牌阶段开始时，你可以将一张非红桃基本牌置于一名判定区没有牌的角色的判定区，若你置于自己的判定区，你摸两张牌。(方块视为乐不思蜀，黑色牌视为兵粮寸断）",
  ["luaZizhong"] = "自重",
  [":luaZizhong"] = "<b>锁定技</b>，你的手牌上限+X（X为你装备区与判定区的牌数之和）；若你的判定区内有牌，其他角色计算与你的距离时，始终+1。",
  ["@luaBinglve"] = "请选择“兵略”技能对象",
  ["~luaBinglve"] = "选择一张非红桃基本牌→选择一名目标→单击确定",
  ["luabinglve"] = "兵略",
}
---------------------------------------------------------------------------------------------------------------------------------------------
Jsimayi = sgs.General(extension,"Jsimayi","jin","3")

luaQice = sgs.CreateTriggerSkill{
  name = "luaQice",
  events = {sgs.CardUsed},
  on_trigger = function(self,event,player,data)
      local use = data:toCardUse()
      local room = player:getRoom()
      local card = use.card
      local suit_string = card:getSuitString()
      if card:isKindOf("TrickCard") and player:askForSkillInvoke(self:objectName()) then 
        local judge = sgs.JudgeStruct()
        judge.who = player
        judge.pattern =  string.format(".|%s",suit_string)
        judge.play_animation = true
        judge.negative = false
        judge.good = true
        room:judge(judge)
        if judge:isGood() then 
          card:toTrick():setCancelable(false)
        end
      end
  end
}
Jsimayi:addSkill(luaQice)

luaJuzhan = sgs.CreateTriggerSkill{
  name = "luaJuzhan",
  events = {sgs.TargetConfirming,sgs.CardEffected},
  on_trigger = function(self,event,player,data)
    if event == sgs.TargetConfirming then 
      local use = data:toCardUse()
      local card = use.card
      if card:isKindOf("Slash") or card:isKindOf("Duel") then 
        local room = player:getRoom()
        local pattern = string.format(".|%s",card:getSuitString())
        if room:askForCard(player,pattern,"@luaJuzhan",data) then
          player:setMark(self:objectName(),1)
        end
      end
      elseif event == sgs.CardEffected then 
      if player:getMark(self:objectName()) > 0 then 
        player:removeMark(self:objectName())
        return true 
      end
    end
  end
}

Jsimayi:addSkill(luaJuzhan)

luaJianbi = sgs.CreateTriggerSkill{
  name = "luaJianbi",
  frequency = sgs.Skill_Compulsory,
  events = {sgs.CardsMoveOneTime,sgs.BeforeCardsMove,sgs.DamageInflicted},
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    if event == sgs.DamageInflicted then 
       if not player:getArmor() then
           local damage = data:toDamage()
           if (damage.damage > 1)  then 
                room:setEmotion(player, "armor/silver_lion")
                local log = sgs.LogMessage()  
                log.type = "#SilverLion"
                log.from = player
                log.arg = damage.damage
                log.arg2 = "silver_lion"
                room:sendLog(log)
                damage.damage = 1
                data:setValue(damage)
            end
        end
    elseif event == sgs.BeforeCardsMove then 
      local move = data:toMoveOneTime() 
      if move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceEquip then 
        if player:getMark("Armor") == 1 then return false end
        if player:getArmor() then return false end
        local can_invoke = false
        for _, id in sgs.qlist(move.card_ids) do
          if sgs.Sanguosha:getEngineCard(id):isKindOf("Armor") then
            can_invoke = true
            break
          end
        end
        if can_invoke and player:isWounded() then
          room:setEmotion(player, "armor/silver_lion")
          room:recover(player,sgs.RecoverStruct())
        end
      end
    end
    end,
  can_trigger = function(self, target)
    if target then
      if target:isAlive() and target:hasSkill(self:objectName()) then
          if target:getMark("Armor_Nullified")==0 and not target:hasFlag("WuqianTarget") then
            if target:getMark("Equips_Nullified_to_Yourself") == 0 then
              local list = target:getTag("Qinggang"):toStringList()
              return #list == 0
          end
        end
      end
    end
    return false
  end
}
Jsimayi:addSkill(luaJianbi)

sgs.LoadTranslationTable{
  ["Jsimayi"] = "司马懿",
  ["&Jsimayi"] = "司马懿",
  ["#Jsimayi"] = "冢虎",
  ["luaQice"] = "奇策",
  [":luaQice"] = "每次你使用锦囊牌时你可以说出一种花色然后进行一次判定，若判定牌与所说花色吻合，你打出的这张牌不能被【无懈可击】",
  ["luaJuzhan"] = "拒战",
  [":luaJuzhan"] = "当你成为【杀】或【决斗】的目标时，你可以弃一张相同花色的牌来抵消那次的攻击。",
  ["@luaJuzhan"] = "你可以打出一张同花色的牌发动“拒战”",
  ["luaJianbi"] = "坚壁",
  [":luaJianbi"] = " <b>锁定技</b> 当你没装备防具时，始终视为你装备着【白银狮子】，装备任意防具后恢复1点体力。",
}
-------------------------------------------------------------------------------------------------------------------------------------------
Jzhangchunhua = sgs.General(extension,"Jzhangchunhua","jin","3",false)

luashuangren = sgs.CreateTriggerSkill{
  name = "luashuangren",
  events = {sgs.DamageCaused},
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    local damage = data:toDamage()
    local victim = damage.to
      local list = room:getOtherPlayers(player)
      local froms = sgs.SPlayerList()
      local card_type_table = {}
      for _, equip in sgs.qlist(player:getEquips()) do 
        local equip_type = equip:getSubtype()
        table.insert(card_type_table,equip_type)
      end
      for _, trick in sgs.qlist(player:getJudgingArea()) do
        local trick_name = trick:objectName()
        table.insert(card_type_table,trick_name)
      end 
      local disabled_ids = sgs.IntList()
      for _, target in sgs.qlist(list) do 
        local can_invoke = false
       for _, equip in sgs.qlist(target:getEquips()) do 
        local equip_type = equip:getSubtype()
        if (not table.contains(card_type_table,equip_type)) then 
          can_invoke = true 
        else  disabled_ids:append(equip:getEffectiveId())
        end
        end
        for _, trick in sgs.qlist(target:getJudgingArea()) do
          local trick_name = trick:objectName()
          if (not table.contains(card_type_table,trick_name)) then 
            can_invoke = true 
          else disabled_ids:append(trick:getEffectiveId())
          end
        end
        if can_invoke then 
          froms:append(target)
        end
      end
     if froms:isEmpty() then return false end 
      local prompt_table = {
      "@shuangren_choose",
      player:objectName(),
      victim:objectName(),
      string.format("%d",damage.damage),
    }
     local prompt = table.concat(prompt_table, ":")
     local target = room:askForPlayerChosen(player,froms,self:objectName(),prompt,true)
     if target == nil then return false end
     room:broadcastSkillInvoke("luashuangren")
     local id = room:askForCardChosen(player,target,"ej",self:objectName(),false,sgs.Card_MethodNone,disabled_ids)
     local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, player:objectName(), self:objectName(), "")
     local card = sgs.Sanguosha:getCard(id)
     local place = room:getCardPlace(id)
     room:moveCardTo(card,target,player,place,reason)
     if place == sgs.Card_PlaceDelayedTrick then 
      player:drawCards(1,self:objectName())
    end
     return true 
  end
}
Jzhangchunhua:addSkill(luashuangren)

luafeishi = sgs.CreateTriggerSkill{
  name = "luafeishi",
  frequency = sgs.Skill_NotFrequent,
  events = {sgs.EventPhaseChanging},
  on_trigger = function(self, event, player, data)
    local room = player:getRoom()
    local change = data:toPhaseChange()
    local nextphase = change.to
    if nextphase == sgs.Player_Judge then
      if not player:isSkipped(sgs.Player_Judge) then
        if not player:isSkipped(sgs.Player_Draw) then
         if player:askForSkillInvoke(self:objectName()) then 
            room:broadcastSkillInvoke("luafeishi",1)
            player:skip(sgs.Player_Judge)
            player:skip(sgs.Player_Draw)
            player:setMark(self:objectName(),1)
          end
        end
      end
    elseif nextphase == sgs.Player_NotActive then 
      if player:getMark(self:objectName()) > 0 then 
        player:removeMark(self:objectName())
        local x = player:getJudgingArea():length()
        room:broadcastSkillInvoke("luafeishi",2)
        player:drawCards(2+x,self:objectName())
      end
    end
    return false
  end
}
Jzhangchunhua:addSkill(luafeishi)

sgs.LoadTranslationTable{
  ["Jzhangchunhua"] = "张春华",
  ["&Jzhangchunhua"] = "张春华",
  ["#Jzhangchunhua"] = "晋室母仪",
  ["luashuangren"] = "霜刃",
  [":luashuangren"] = "每当你造成一次伤害时，可以防止此伤害并将场上的一张牌移动至你区域内的相应位置，若该牌为锦囊牌，你摸一张牌。",
  ["@shuangren_choose"] = "请选择“霜刃”技能对象，伤害对象为%dest",
  ["luafeishi"] = "废食",
  [":luafeishi"] = "你可以跳过你的判定阶段与摸牌阶段，然后于此回合结束时摸2+X张牌。X为你判定区牌的数量。" ,
  ["$luafeishi1"] = "无情者伤人，有情者自伤。",
  ["$luafeishi2"] = "失礼了~",
  ["$luashuangren"] = "看我的厉害！", 
}
------------------------------------------------------------------------------------------------------------------------------------
Jweiguan = sgs.General(extension,"Jweiguan","jin","4")

luaJianjun = sgs.CreateTriggerSkill{
  name = "luaJianjun",
  frequency = sgs.Skill_Compulsory,
  events = {sgs.BeforeCardsMove,sgs.ChoiceMade,sgs.CardFinished},
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    for _, target in sgs.qlist(room:getOtherPlayers(player)) do 
       room:removeAttackRangePair(player,target)
       if target:getMaxHp() == player:getMaxHp() or target:getJudgingArea():length() > 0 then 
       room:insertAttackRangePair(player,target)
      end
    end
  end
}
Jweiguan:addSkill(luaJianjun)

luaZhenluan = sgs.CreateTriggerSkill{
  name = "luaZhenluan",
  events = {sgs.EventPhaseStart,sgs.GameStart},
  on_trigger = function(self,event,player,data)
  local room = player:getRoom()
  if event == sgs.EventPhaseStart then 
    if player:getPhase() == sgs.Player_Play then 
      local chained_list = sgs.SPlayerList()
      local unchained_list = sgs.SPlayerList()
      for _, target in sgs.qlist(room:getAlivePlayers()) do
          if (not target:isChained())  then 
            if player:inMyAttackRange(target) then unchained_list:append(target)
          end
          else
            if (not player:isKongcheng()) then chained_list:append(target) end
        end
      end
      local choicelist = {}
      table.insert(choicelist,"cancel")
      if  (not unchained_list:isEmpty()) then table.insert(choicelist,"setChained") end
      if (not chained_list:isEmpty()) then table.insert(choicelist,"dofire_attack") end
      local choice = table.concat(choicelist, "+")
      local result = room:askForChoice(player,self:objectName(),choice)
      if result == "setChained" then 
        local target = room:askForPlayerChosen(player,unchained_list,self:objectName(),"@setChained")
         target:setChained(true)
         room:broadcastProperty(target, "chained")
         room:setEmotion(target, "chain")
         local thread = room:getThread()
         thread:trigger(sgs.ChainStateChanged,room,target)
      elseif result == "dofire_attack" then 
        local fire_attack = sgs.Sanguosha:cloneCard("fire_attack",sgs.Card_NoSuit,0)
        local target = room:askForPlayerChosen(player,chained_list,self:objectName(),"@dofire_attack")
        room:useCard(sgs.CardUseStruct(fire_attack,player,target))
      elseif result == "cancel" then return false 
    end
  end
  elseif event == sgs.GameStart then 
    room:loseHp(player)
  end
  end
}
Jweiguan:addSkill(luaZhenluan)

yizhi_buff = sgs.CreateMaxCardsSkill{ 
  name = "#yizhi_buff",
  extra_func = function(self,target)
    if target:hasSkill(self:objectName()) then 
       return 1
     end
  end 
}

local Skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("#yizhi_buff") then
Skills:append(yizhi_buff)
end
sgs.Sanguosha:addSkills(Skills)

luaYizhi = sgs.CreateTriggerSkill{
  name = "luaYizhi",
  frequency = sgs.Skill_Limited,
  events = {sgs.GameStart,sgs.EventPhaseChanging},
  on_trigger = function(self,event,player,data)
    if event == sgs.GameStart then 
      player:gainMark("@yi")
      elseif event == sgs.EventPhaseChanging then 
        local room = player:getRoom()
        local change = data:toPhaseChange()
        if change.to == sgs.Player_NotActive then 
          if player:getMark("@yi") == 0 then return false end
          if player:askForSkillInvoke(self:objectName()) then 
            room:loseMaxHp(player)
            player:loseMark("@yi")
            for _, target in sgs.qlist(room:getAlivePlayers()) do 
               room:acquireSkill(target,"#yizhi_buff")
             end
           end
         end
       end         
  end
}
Jweiguan:addSkill(luaYizhi)

sgs.LoadTranslationTable{
  ["Jweiguan"] = "卫瓘",
  ["&Jweiguan"] = "卫瓘",
  ["#Jweiguan"] = "至真之风",
  ["@yi"] = "议制",
  ["luaJianjun"] = "监军",
  [":luaJianjun"] = "<b>锁定技</b>，判定区有牌或体力上限与你相同的角色均视为在你攻击范围内",
  ["luaZhenluan"] = "镇乱",
  [":luaZhenluan"] = "出牌阶段开始时，你可以选择一项：横置攻击范围内一名角色的武将牌，或视为对一名武将牌横置的角色使用了一张【火攻】。 ",
  ["setChained"] = "横置攻击范围内一名角色的武将牌",
  ["dofire_attack"] = "视为对一名武将牌横置的角色使用了一张【火攻】。",
  ["@setChained"] = "你可以横置攻击范围内一名角色的武将牌",
  ["@dofire_attack"] = "你可以对一名武将牌横置的角色使用了一张【火攻】。",
  ["luaYizhi"] = "议制",
  [":luaYizhi"] = "<b>限定技</b>，回合结束时，你可以减一点体力上限，然后令所有角色的手牌上限+1直到游戏结束。",
}
-----------------------------------------------------------------------------------------------------------------------------------
Jwangji = sgs.General(extension,"Jwangji","jin","4")

luaWeiquan = sgs.CreateTriggerSkill{
  name = "luaWeiquan",
  frequency = sgs.Skill_Compulsory,
  events = {sgs.TargetConfirming,sgs.SlashMissed},
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    if event == sgs.TargetConfirming then
      local use = data:toCardUse()
      local source = use.from
      if use.card:isKindOf("Slash") then 
        if source:hasSkill(self:objectName()) then
          source:drawCards(1,self:objectName())
        elseif player:hasSkill(self:objectName()) then 
          player:drawCards(1,self:objectName())
        end
      end
      elseif event == sgs.SlashMissed then 
      local effect = data:toSlashEffect()
      local target = effect.to
      local dest 
      if player:hasSkill(self:objectName()) then 
         dest = player
         elseif target:hasSkill(self:objectName()) then 
          dest = target
        end
        local choicelist
        if not dest then return false end
        if dest:isKongcheng() then choicelist = "loseHp" 
          else choicelist = "putHandcard+loseHp"
          end
        local result = room:askForChoice(dest,self:objectName(),choicelist)
        if result == "loseHp" then 
          room:loseHp(dest)
        elseif result == "putHandcard" then 
          local card = room:askForExchange(dest,self:objectName(),1,1,false,"@weiquan_choose")
          local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, dest:objectName(), self:objectName(), "")
          room:moveCardTo(card,dest,nil,sgs.Player_DrawPile,reason)
        end
      end       
  end,
  can_trigger = function(self,target)
    return target:isAlive()
  end
}

Jwangji:addSkill(luaWeiquan)

sgs.LoadTranslationTable{
  ["Jwangji"] = "王基" ,
  ["&Jwangji"] = "王基",
  ["#Jwangji"] = "宿卫之臣",
  ["luaWeiquan"] = "威权",
  [":luaWeiquan"] = "<b>锁定技</b>，每当你使用或被使用一张杀时，你须摸一张牌，若此杀未造成伤害，你须选择一项：将一张手牌置于牌堆顶，或失去一点体力。",
  ["loseHp"] = "失去一点体力",
  ["putHandcard"] = "将一张手牌置于牌堆顶",
  ["@weiquan_choose"] = "请选择一张手牌放于牌堆顶",
}
-------------------------------------------------------------------------------------------------------------------------------------------------
Jwangxiang = sgs.General(extension,"Jwangxiang","jin","3")

luaWobingCard = sgs.CreateSkillCard{
  name = "luaWobing",
  target_fixed = true,
  on_use = function(self,room,source,targets)
    local judge = sgs.JudgeStruct()
     judge.who = source
     judge.pattern =  ".|heart"
     judge.play_animation = true
     judge.negative = false
     judge.good = true
     room:judge(judge)
     local target = room:askForPlayerChosen(source,room:getAlivePlayers(),self:objectName(),"@wobing_choose")
     target:obtainCard(judge.card)
      if judge:isBad() then
        room:damage(sgs.DamageStruct("luaWobing",nil,source))
      end
  end
}

luaWobing = sgs.CreateZeroCardViewAsSkill{
  name = "luaWobing",
  view_as=function()
  return luaWobingCard:clone()
  end,
  enabled_at_play=function(self,player)
  return (not player:hasUsed("#luaWobing"))
 end
}

Jwangxiang:addSkill(luaWobing)

luaweijie = sgs.CreateTriggerSkill{
  name = "luaweijie" ,
  events = {sgs.Damaged} ,
  on_trigger = function(self, event, player, data)
    local damage = data:toDamage()
    local room = player:getRoom()
      local to = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), "@weijie-invoke", true, true)
      if not to then return false end 
      room:broadcastSkillInvoke("luaweijie",1)
      local upper = to:getMaxHp()
      local x = upper - to:getHandcardNum()
      if x <= 0 then
      else
        to:drawCards(x,self:objectName())
      end
       local card = room:askForExchange(to,self:objectName(),1,1,true,"@weijie_choose")
       player:obtainCard(card)
  end
}

Jwangxiang:addSkill(luaweijie)
sgs.LoadTranslationTable{
  ["Jwangxiang"] = "王祥",
  ["&Jwangxiang"] = "王祥",
  ["#Jwangxiang"] = "众臣第一",
  ["luaWobing"] = "卧冰",
  [":luaWobing"] = "<b>阶段技</b>，出牌阶段，你可以进行一次判定，然后令一名角色获得判定结果，若结果不为红桃，你受到一点无来源的伤害。",
  ["luawobing"] = "卧冰",
  ["@wobing_choose"] = "请选择一名玩家得到判定结果",
  ["luaweijie"] = "伪节" ,
  [":luaweijie"] = "每当你受到一次伤害后，可以令一名角色将手牌补至体力值的张数，然后其须交给你一张牌。",
  ["$luaweijie1"] = "或忠信而死节兮，或訑谩而不疑。",
  ["@weijie-invoke"] = "请选择“伪节”的对象",
  ["@weijie_choose"] = "请交给王祥一张牌",
}
------------------------------------------------------------------------------------------------------------------------------------------
Jzhouchu = sgs.General(extension,"Jzhouchu","jin","5")

luabaohan = sgs.CreateTriggerSkill{
  name = "luabaohan",
  frequency = sgs.Skill_Compulsory,
  events = {sgs.Damage},
  on_trigger = function(self,event,player,data)
    local damage = data:toDamage()
    local room = player:getRoom()
    local target = damage.to
    room:broadcastSkillInvoke("luabaohan",1)
    for _, victim in sgs.qlist(room:getOtherPlayers(target)) do 
      if victim:distanceTo(target) == 1 then 
        room:loseHp(victim)
      end
    end
  end
}
Jzhouchu:addSkill(luabaohan)

luachuhai = sgs.CreateTriggerSkill{
  name = "luachuhai",
  frequency = sgs.Skill_Wake,
  events = {sgs.Death,sgs.EventPhaseChanging},
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    if event == sgs.Death then
      if player:getPhase() ~= sgs.Player_NotActive then 
        player:setMark("chuhai_death",1)
        end
    elseif event == sgs.EventPhaseChanging then 
      local change = data:toPhaseChange()
      if change.to == sgs.Player_NotActive then 
        if player:getMark("chuhai_death") > 0 then 
          room:broadcastSkillInvoke("luachuhai",1)
          player:setMark(self:objectName(),1)
          player:gainMark("@waked")
          room:loseMaxHp(player)
          room:detachSkillFromPlayer(player,"luabaohan")
          room:acquireSkill(player,"jiangchi")
          room:doLightbox("$chuhai")
        end
      end
    end
  end,
  can_trigger = function(self,target)
     return target and target:isAlive() and target:hasSkill(self:objectName()) 
        and target:getMark(self:objectName()) == 0
        and target:getMark("@waked") == 0
  end
}
Jzhouchu:addSkill(luachuhai)
sgs.LoadTranslationTable{
  ["Jzhouchu"] = "周处",
  ["&Jzhouchu"] = "周处",
  ["#Jzhouchu"] = "浪子回头",
  ["luabaohan"] = "暴悍",
  [":luabaohan"] = "<b>锁定技</b>，每当你对一名角色造成一次伤害后，与其距离为一的角色须各失去一点体力。",
  ["luachuhai"] = "除害",
  [":luachuhai"] = "<b>觉醒技</b>，回合结束时，若本回合有角色死亡，你须减一点体力上限并失去一点体力，然后失去技能“暴悍”并获得技能“将驰”。",
  ["$chuhai"] = "浪子回头终不晚",
  ["$luabaohan1"] = "神挡杀神，佛挡杀佛！",
  ["$luachuhai1"] = "士别三日，刮目相看。",
}
---------------------------------------------------------------------------------------------------------------------------------------------
Jzhanghua = sgs.General(extension,"Jzhanghua","jin","3")

luajianzhi = sgs.CreateTriggerSkill{
  name = "luajianzhi",
  events = {sgs.SlashMissed},
  on_trigger = function(self,event,player,data)
    local room = player:getRoom()
    local zhanghua = room:findPlayerBySkillName(self:objectName())
    if zhanghua:inMyAttackRange(player) then 
      local effect = data:toSlashEffect()
      if room:askForCard(zhanghua,".|red","@jianzhi_discard",data) then
          room:broadcastSkillInvoke("luajianzhi",1)
          room:slashResult(effect, nil)
        end
      end
  end,
  can_trigger = function(self,target)
    return target ~= nil
  end
}
Jzhanghua:addSkill(luajianzhi)

lualezhi = sgs.CreateTriggerSkill{
  name = "lualezhi",
  events = {sgs.TargetConfirming},
  on_trigger = function(self,event,player,data)
     local room = player:getRoom()
     local use = data:toCardUse()
     if use.card:isKindOf("TrickCard") then 
      room:broadcastSkillInvoke("lualezhi",1)
      player:drawCards(1,self:objectName())
    end
  end
}
Jzhanghua:addSkill(lualezhi)
sgs.LoadTranslationTable{
  ["Jzhanghua"] = "张华",
  ["&Jzhanghua"] = "张华",
  ["#Jzhanghua"] = "博闻无双",
  ["luajianzhi"] = "坚执",
  [":luajianzhi"] = "你攻击范围内的一名角色使用的杀被目标角色的闪抵消后，你可以弃置一张红色牌，则此杀继续造成伤害。",
  ["lualezhi"] = "乐志",
  [":lualezhi"] = "每当你被使用一张锦囊牌时，你可以摸一张牌。",
  ["@jianzhi_discard"] = "你可以弃一张牌，让此杀生效",
  ["$luajianzhi1"] = "如此，一击可擒也！",
  ["$lualezhi1"] = "就这样吧。",
}


