return function()
  local QuestService = require(script.Parent.Parent.QuestService)
  local QuestDefinitions = require(script.Parent.Parent.QuestDefinitions)

  describe("QuestService", function()
    it("loads quest definitions", function()
      expect(QuestDefinitions.Q1_PLAYGROUND).to.be.ok()
    end)

    it("exposes quest lifecycle methods", function()
      expect(QuestService.Init).to.be.ok()
      expect(QuestService.StartQuest).to.be.ok()
      expect(QuestService.GetState).to.be.ok()
    end)
  end)
end
