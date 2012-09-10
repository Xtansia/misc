--[[
Advanced Vector API by Tomass1996

Vector 'Object' Functions And Fields:
  vector.x				-- Vectors X component
  vector.y				-- Vectors Y component
  vector.z				-- Vectors Z component
  vector:add(otherVector) 		-- Component-wise addition
  vector:scalarAdd(n)			-- Scalar addition
  vector:subtract(otherVector)		-- Component-wise subtraction
  vector:scalarSubtract(n)		-- Scalar subtraction
  vector:multiply(otherVector) 		-- Component-wise multiplication
  vector:scalarMultiply(n)		-- Scalar multiplication
  vector:divide(otherVector)		-- Component-wise division
  vector:scalarDivide(n)		-- Scalar division
  vector:length()			-- Get the length of the vector
  vector:lengthSq()			-- Get the length ^ 2 of the vector
  vector:distance(otherVector)		-- Get the distance away from a vector
  vector:distanceSq(otherVector)	-- Get the distance away from a vector, squared
  vector:normalize()			-- Get the normalized vector
  vector:dot(otherVector)		-- Get the dot product of vector and otherVector
  vector:cross(otherVector)		-- Get the cross product of vector and otherVector
  vector:containedWithin(minVec, maxVec)-- Check to see if vector is contained within minVec and maxVec
  vector:clampX(min, max)		-- Clamp the X component
  vector:clampY(min, max)		-- Clamp the Y component
  vector:clampZ(min, max)		-- Clamp the Z component
  vector:floor()			-- Rounds all components down
  vector:ceil()				-- Rounds all components up
  vector:round()			-- Rounds all components to the closest integer
  vector:absolute()			-- Vector with absolute values of components
  vector:isCollinearWith(otherVector)	-- Checks to see if vector is collinear with otherVector
  vector:getIntermediateWithX(other, x)	-- New vector with given x value along the line between vector and other, or nil if not possible
  vector:getIntermediateWithY(other, y)	-- New vector with given y value along the line between vector and other, or nil if not possible
  vector:getIntermediateWithZ(other, z)	-- New vector with given z value along the line between vector and other, or nil if not possible
  vector:rotateAroundX(angle)		-- Rotates vector around the x axis by the specified angle(radians)
  vector:rotateAroundY(angle)		-- Rotates vector around the y axis by the specified angle(radians)
  vector:rotateAroundZ(angle)		-- Rotates vector around the z axis by the specified angle(radians)
  vector:clone()			-- Returns a new vector with same component values as vector
  vector:equals(otherVector)		-- Checks to see if vector and otherVector are equal
  vector:tostring()			-- Returns the string representation of vector "(x, y, z)"

Vector 'Object' Metatable Overrides:  	-- [x, y, z] represents a vector object in these examples, not irl
  To String		-- tostring will get the string representation
			    ie.	tostring([1, 2, 3])	-->	"(1, 2, 3)"
  Unary Minus		-- Using unary minus on a vector will result in the negative of vector
			    ie.	-[1, -2, 3]		-->	[-1, 2, -3]
  Addition		-- Can add two vectors or vector and number with +
			    ie.	[1, 2, 3] + [4, 5, 6]	-->	[5, 7, 9]
				[1, 2, 3] + 3		-->	[4, 5, 6]
  Subtraction		-- Can subtract two vectors or vector and number with -
			    ie.	[4, 5, 6] - [1, 2, 3]	-->	[3, 3, 3]
				[4, 5, 6] - 3		-->	[1, 2, 3]
  Multiplication	-- Can multiply two vectors or vector and number with *
			    ie.	[1, 2, 3] * [4, 5, 6]	-->	[4, 10, 18]
				[1, 2, 3] * 3		-->	[3, 6, 9]
  Division		-- Can divide two vectors or vector and number with /
			    ie.	[4, 10, 18] / [1, 2, 3]	-->	[4, 5, 6]
				[3, 6, 9] / 3		-->	[1, 2, 3]
  Equality		-- Can check if two vectors are the same with ==
			    ie.	[4, 5, 6] == [4, 5, 6]	-->	true
				[4, 5, 6] == [4, 99, 6]	-->	false

Vector API functions:
  Vector.getMinimum(v1, v2)		-- Gets the minimum components of two vectors
  Vector.getMaximum(v1, v2)		-- Gets the maximum components of two vectors
  Vector.getMidpoint(v1, v2)		-- Gets the midpoint of two vectors
  Vector.isVector(v)			-- Checks whether v is a vector created by this api
  Vector.new(x, y, z)			-- Creates a new vector object with the component values
--]]