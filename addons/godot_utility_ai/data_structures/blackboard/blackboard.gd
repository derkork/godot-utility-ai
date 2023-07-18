## A blackboard where information can be stored and retrieved.
class_name Blackboard

## The key which will be used to store per-object blackboards in the meta information.
const BLACKBOARD_META_KEY:String = "__GUA_blackboard"

## The global blackboard's contents.
static var _contents:Dictionary = {}


## Stores a piece of information on the blackboard under the given key.
static func store(key:StringName, value:Variant) -> void:
	_contents[key] = value
	
## Stores a piece of information for the given context object under the given key
## The information will be automatically removed when the object is discarded.
static func store_for(context:Object, key:StringName, value:Variant) -> void:
	if not is_instance_valid(context):
		push_warning("Given context object is not valid, nothing will be stored.")
		return
		
	if not context.has_meta(BLACKBOARD_META_KEY):
		context.set_meta(BLACKBOARD_META_KEY, {})
		
	context.get_meta(BLACKBOARD_META_KEY)[key] = value
	
## Retrives a piece of information from the blackboard using the given key. 
## Returns the given default value if the key is not known.
static func retrieve(key:StringName, default:Variant = null) -> Variant:
	return _contents.get(key, default)
	

## Retrieves a piece of information for the given  context object under the given key
## If the context object is no longer valid, will return the default value	
static func retrieve_for(context:Object, key:StringName, default:Variant = null) -> Variant:
	if not is_instance_valid(context):
		return default
		
	if not context.has_meta(BLACKBOARD_META_KEY):
		return default
		
	return context.get_meta(BLACKBOARD_META_KEY).get(key, default)
	
	
