require_relative "const/const"
require_relative "color/color"
require_relative "core_ext/hash/hash"
require_relative "core_ext/string/string"
require_relative "core_ext/file/file"
require_relative "utils/utils"

include ColorTree::Const
include ColorTree::Color
include ColorTree::CoreExt::Hash
include ColorTree::CoreExt::String
include ColorTree::CoreExt::File
include ColorTree::Utils
include AbortIf
