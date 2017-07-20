# Tinkerbell Slices

A slice is a read-only random access data structure that is based on a vector, an offset, a length and a direction, meaning that trimming and reversal become very cheap operations. Think ES5 array views. The API should be self-explanatory. Noteworthy details are documented inline.