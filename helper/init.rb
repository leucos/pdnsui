# Define a subclass of Ramaze::Controller holding your defaults for all controllers. Note 
# that these changes can be overwritten in sub controllers by simply calling the method 
# but with a different value.

module PDNSui
end

require __DIR__('restify')
require __DIR__('sidebar')
require __DIR__('model_exception_wrapper')
