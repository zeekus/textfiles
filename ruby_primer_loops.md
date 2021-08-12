## Ruby Primer loops

# while loop 

```
x=0
while x<10
   x=x+1
   puts x
end
```

# for loop 

```
for a in 1..5 do
 puts a
end
```

# for loop array

```
array=["I", "like", "cheese"]

for i in array do
   puts i
end
```

# until loop

```
x=1
until x > 10
  puts x
  x=x+1
end
```

# for each

```
array=["1", "2"]
array.each do |e|
   puts e
end
```
# alternative syntax
```
array.each {  |e|
   puts e
}
```

# count 10 with for loop

```
counter=(1..10).to_a # two dots for exact range 
for x in counter do
  puts x
end
```

# alternative do each loop to 10

```
counter=(1...11) # three dots for stopping one before end of range
counter.each do |x|
  puts x
end
```

