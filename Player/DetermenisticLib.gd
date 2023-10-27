extends Spatial








func Clamp(Value:int,Min:int,Max:int) -> int: # Value Min Max #
	if Value >= Max:
		Value = Max
	if Value <= Min:
		Value = Min
	if Value >= Max:
		Value = Max
	if Value <= Min:
		Value = Min
	return Value
