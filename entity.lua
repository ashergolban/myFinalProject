Entity = Object:extend()

-- Base calss for all game entities
function Entity:new(x, y, image_path)
    -- Intialize x and y position of the entity
    self.x = x
    self.y = y

    -- Load the image for this entity
    self.image = love.graphics.newImage(image_path)

    -- Get the dimensions of the image for drawing and collisions
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
end

function Entity:update(dt)
    -- Placeholder for logic updates
end

function Entity:draw()
    -- Draw the entity at its current position
    love.graphics.draw(self.image, self.x, self.y)
end