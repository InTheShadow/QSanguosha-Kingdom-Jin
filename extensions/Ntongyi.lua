module("extensions.Ntongyi", package.seeall)
extension = sgs.Package("Ntongyi")
--------------------------------------------------------------------------------------------------------------------------------------------
nos_wenyang = sgs.General(extension,"nos_wenyang","jin","4")

luanos_tuying = sgs.CreateTriggerSkill{
  name = "luanos_tuying",
  frequency = sgs.Skill_Frequent,
  events = {sgs.DamageInflicted},
  on_trigger = function(self,event,player,data)
     local damage = data:toDamage() 
        local room = player:getRoom()
        local source = damage.from 
        if damage.card and damage.card:isKindOf("Slash") and 
          source and (source:objectName() ~= player:objectName()) and source:isAlive() and player:isAlive()  then  
          local source_data = sgs.QVariant()
           source_data:setValue(source)
          if room:askForSkillInvoke(player, self:objectName(), source_data) then
            local card
              local card = room:askForCard(source, "BasicCard|.|.|hand", "@tuyingbasic"..player:objectName(), data, sgs.Card_MethodNone)
             if card then
              room:broadcastSkillInvoke("luanos_tuying",1)
             room:showCard(source,card:getEffectiveId())
             player:obtainCard(card)
             else
              room:broadcastSkillInvoke("luanos_tuying",2)
              local Damage = sgs.DamageStruct()
              Damage.damage = damage.damage
              Damage.to = source
              Damage.from = player
              room:damage(Damage)
            end
         end
        end
      end
    }

nos_wenyang:addSkill(luanos_tuying) 

sgs.LoadTranslationTable{
   ["Ntongyi"] = "新三国统一包",
   ["nos_wenyang"] = "文鸯-旧",
   ["&nos_wenyang"] = "文鸯-旧",
   ["#nos_wenyang"] = "勇冠三军", 
   ["luanos_tuying"] = "突营",
   [":luanos_tuying"] = "当一名其他角色使用【杀】对你造成伤害时，你可以令该角色展示并交给你一张基本牌，否则你对其造成相同的伤害。",
   ["@tuyingbasic"] = "请交给%src一张基本牌",
   ["$luanos_tuying1"] = "拿来吧！",
   ["$luanos_tuying2"] = "以彼之道，还施彼身！",
 }
 ----------------------------------------------------------------------------------------------------------------------------
 NJ_simayi = sgs.General(extension,"NJ_simayi","jin","4")

 luarenxun = sgs.CreateTriggerSkill{
   name = "luarenxun",
   frequency = sgs.Skill_Compulsory,
   events = {sgs.Damaged,sgs.HpRecover},
   on_trigger = function(self,event,player,data)
     local room = player:getRoom()
     if event == sgs.Damaged then
      local x = data:toDamage().damage
      for i = 1,x,1 do
        local mhp = player:getMaxHp()
        room:setPlayerProperty(player,"maxhp",sgs.QVariant(mhp+1))
      end
      elseif event == sgs.HpRecover then 
        local x = data:toRecover().recover
       for i = 1,x,1 do
        room:loseMaxHp(player)
      end
    end
   end
}
NJ_simayi:addSkill(luarenxun)

luaduoji = sgs.CreateTriggerSkill{
  name = "luaduoji",
  events = {sgs.EventPhaseChanging},
  on_trigger = function(self,event,player,data)
    local change = data:toPhaseChange()
    if change.to == sgs.Player_NotActive then 
      local room = player:getRoom()
      local x = player:getLostHp()
      if x == 0 then return false end
      if player:askForSkillInvoke(self:objectName()) then
         local ids = room:getNCards(x)
         room:fillAG(ids,player)
         local id = room:askForAG(player,ids,false,self:objectName())
         ids:removeOne(id)
         room:clearAG(player)
         local choice = room:askForChoice(player,self:objectName(),"obtain+putover")
         local card = sgs.Sanguosha:getCard(id)
         if choice == "obtain" then 
          player:obtainCard(card) 
        elseif choice == "putover" then 
        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), self:objectName(), "")
        room:moveCardTo(card,player,nil,sgs.Player_DrawPile,reason)
        end
         if not ids:isEmpty() then 
          room:askForGuanxing(player,ids,sgs.Room_GuanxingDownOnly)
        end
      end
    end
  end
  }
  NJ_simayi:addSkill(luaduoji)
  sgs.LoadTranslationTable{
    ["NJ_simayi"] = "新司马懿",
    ["&NJ_simayi"] = "司马懿",
    ["#NJ_simayi"] = "宣王创世",
    ["luarenxun"] = "忍训",
    [":luarenxun"] = "<font color=\"blue\"><b>锁定技</b></font>,每当你受到一次伤害后，你须增加一点体力上限；每当你回复一次体力后，你须减一点体力上限。",
    ["luaduoji"] = "度机",
    [":luaduoji"] = "回合结束时，你可以观看牌堆底的X张牌，然后你可以展示其中一张并选择一项：获得之，或将之置于牌堆顶，其余以任意顺序置于牌堆底。X为你已损失的体力值。",
    ["obtain"] = "获得卡牌",
    ["putover"] = "将此牌置于牌堆顶",
  }
---------------------------------------------------------------------------------------------------------------------------
NJ_simashi = sgs.General(extension,"NJ_simashi","jin","4")

luazhenggang = sgs.CreateTriggerSkill{
  name = "luazhenggang",
  events = {sgs.EventPhaseStart,sgs.GameStart},
  on_trigger = function(self,event,player,data)
   local room = player:getRoom()
   if event == sgs.EventPhaseStart then 
    if player:getPhase() == sgs.Player_Judge then 
      local choice_table = {}
      local targets = sgs.SPlayerList()
      for _, target in sgs.qlist(room:getAlivePlayers()) do 
         if (not target:getEquips():isEmpty()) or(not target:getJudgingArea():isEmpty()) then targets:append(target) end
      end
      if (not player:isKongcheng()) then table.insert(choice_table,"zhenggang_increase") end
      if player:getMaxHp() ~= 1 and (not targets:isEmpty()) then  table.insert(choice_table,"zhenggang_decrease") end
      table.insert(choice_table,"cancel")
      local choice = table.concat(choice_table,"+")
      local result = room:askForChoice(player,self:objectName(),choice)
      if result == "cancel" then return false 
      elseif result == "zhenggang_decrease" then 
        room:loseMaxHp(player)
        local target = room:askForPlayerChosen(player,targets,self:objectName(),"@zhenggang_decrease") 
        local id = room:askForCardChosen(player,target,"ej",self:objectName())
        local card = sgs.Sanguosha:getCard(id)
        player:obtainCard(card)
     elseif result == "zhenggang_increase" then
       local mhp = player:getMaxHp() 
       room:setPlayerProperty(player,"maxhp",sgs.QVariant(mhp+1))
       local card = room:askForExchange(player,self:objectName(),1,1,false,"@zhenggang_increase")
       local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), self:objectName(), "")
       room:moveCardTo(card,player,nil,sgs.Player_DrawPile,reason)
     end
   end
   elseif event == sgs.GameStart then 
    room:loseHp(player)
  end
  end
}
NJ_simashi:addSkill(luazhenggang)
luaruilve = sgs.CreateTriggerSkill{
  name = "luaruilve",
  frequency = sgs.Skill_Frequent,
  events = {sgs.EventPhaseChanging},
  on_trigger = function(self,event,player,data)
    local change = data:toPhaseChange()
    if change.to == sgs.Player_NotActive then
      local room = player:getRoom() 
      if player:getHandcardNum()  >= player:getMaxHp() then 
        player:drawCards(1,self:objectName())
      end
    end
  end
}
NJ_simashi:addSkill(luaruilve)
sgs.LoadTranslationTable{
    ["NJ_simashi"] = "司马师",
    ["&NJ_simashi"] = "司马师",
    ["#NJ_simashi"] = "以文制武",
    ["luazhenggang"] = "整纲",
    [":luazhenggang"] = "判定阶段开始时，你可以选择一项：减一点体力上限并获得场上的一张牌，或将一张手牌置于牌堆顶并增加一点体力上限。",
    ["luaruilve"] = "睿略",
    [":luaruilve"] = "回合结束时，若你的手牌数不少于你的体力上限，你可以摸一张牌",
    ["zhenggang_decrease"] = "减一点体力上限并获得场上的一张牌",
    ["zhenggang_increase"] = "将一张手牌置于牌堆顶并增加一点体力上限",
    ["@zhenggang_decrease"] = "请选择一名玩家并获得其场上一张牌",
    ["@zhenggang_increase"] = "请选择一张手牌并置于牌堆顶",
  }