Iterables
The Structures through which we can traverse like list,dict,strings etc
The Iteration Protocol
The built-in function iter takes an iterable object and returns an iterator.
>>> x = iter([1, 2, 3])
>>> x
<listiterator object at 0x1004ca850>
>>> x.next()
1
>>> x.next()
2
>>> x.next()
3
>>> x.next()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
StopIteration
5.2. Generators
Generators simplifies creation of iterators. A generator is a function that produces a sequence of results instead of a single value.
def yrange(n):
    i = 0
    while i < n:
        yield i
        i += 1
Each time the yield statement is executed the function generates a new value.
>>> y = yrange(3)
>>> y
<generator object yrange at 0x401f30>
>>> y.next()
0
>>> y.next()
1
>>> y.next()
2
>>> y.next()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
StopIteration
So a generator is also an iterator. You don’t have to worry about the iterator protocol.
 
Data Structures 
Series
Series is a one-dimensional labeled array capable of holding any data type (integers, strings, floating point numbers, Python objects, etc.). The axis labels are collectively referred to as the index. The basic method to create a Series is to call:
>>> s = pd.Series(data, index=index)
If data is an ndarray, index must be the same length as data. If no index is passed, one will be created having values [0, ..., len(data) - 1].
From dict
Series can be instantiated from dicts:
In [7]: d = {'b': 1, 'a': 0, 'c': 2}

In [8]: pd.Series(d)
Out[8]: 
b    1
a    0
c    2
dtype: int64
From scalar value
If data is a scalar value, an index must be provided. The value will be repeated to match the length of index.
In [12]: pd.Series(5., index=['a', 'b', 'c', 'd', 'e'])
Out[12]: 
a    5.0
b    5.0
c    5.0
d    5.0
e    5.0
dtype: float64
To reference single value s[1]
	To reference multiple s[[1,2]]
Series is dict-like¶
A Series is like a fixed-size dict in that you can get and set values by index label:
In [21]: s['a']
Out[21]: 0.46911229990718628

In [22]: s['e'] = 12.

In [23]: s
Out[23]: 
a     0.469112
b    -0.282863
c    -1.509059
d    -1.135632
e    12.000000
dtype: float64

In [24]: 'e' in s
Out[24]: True

In [25]: 'f' in s
Out[25]: False
Object TypeIndexers
.loc, .iloc, and also [] indexing can accept a callable as indexer
Series	s.loc[indexer]
DataFrame	df.loc[row_indexer,column_indexer]
Panel	p.loc[item_indexer,major_indexer,minor_indexer]
Head and tail
To get top or bottom data in required number
Delting rows and columns
del df['name']
The second argument “1” in function drop(...) denotes deletion of the “Column”, whereas “0” means deletion of the “Row
# Delete Column "age"
df.drop('age',1)
# Delete the Row with Index "3"
df.drop(3,0)
We can also delete multiple Rows and Columns by passing the list in drop(...)function
# Delete Columns "name" & "age"
df.drop(['name','age'],1)
# Delete Rows with index "2","3", & "4"
df.drop([2,3,4],0)
Getting a Series out of a Pandas DataFrame

DataFrame provides two ways of accessing the column i.e by using dictionary syntax df['column_name'] or df.column_name . Each time we use these representation to get a column, we get a Pandas Series.



Sorting
sort_index()  Sorts based on row index unsorted_df.sort_index(ascending=False)
Sort the Columns
By passing the axis argument with a value 0 or 1, the sorting can be done on the column labels. By default, axis=0, sort by row. Let us consider the following example to understand the same.
sorted_df=unsorted_df.sort_index(axis=1)
By Value
Like index sorting, sort_values() is the method for sorting by values. It accepts a 'by' argument which will use the column name of the DataFrame with which the values are to be sorted.
sorted_df = unsorted_df.sort_values(by='col1')

loc takes two single/list/range operator separated by ','. The first one indicates the row and the second one indicates columns.
df = pd.DataFrame(np.random.randn(8, 4),
index = ['a','b','c','d','e','f','g','h'], columns = ['A', 'B', 'C', 'D'])
#select all rows for a specific column
print df.loc[:,'A']
# Select all rows for multiple columns, say list[]
print df.loc[:,['A','C']]
# Select few rows for multiple columns, say list[]
print df.loc[['a','b','f','h'],['A','C']]
# Select range of rows for all columns
print df.loc['a':'h']
# for getting values with a boolean array
print df.loc['a']>0
.iloc()
Pandas provide various methods in order to get purely integer based indexing. Like python and numpy, these are 0-based indexing.
The various access methods are as follows −
•	An Integer
•	A list of integers
•	A range of values
•	df = pd.DataFrame(np.random.randn(8, 4), columns = ['A', 'B', 'C', 'D'])
•	
•	# select all rows for a specific column
•	print df.iloc[:4]
•	# Integer slicing
•	print df.iloc[:4]
•	print df.iloc[1:5, 2:4]
•	print df.iloc[[1, 3, 5], [1, 3]]
•	print df.iloc[1:3, :]
•	print df.iloc[:,1:3]
.ix()
Besides pure label based and integer based, Pandas provides a hybrid method for selections and subsetting the object using the .ix() operator.
# Integer slicing
print df.ix[:4]
# Index slicing
print df.ix[:,'A']
Let us now see how each operation can be performed on the DataFrame object. We will use the basic indexing operator '[ ]' –
df = pd.DataFrame(np.random.randn(8, 4), columns = ['A', 'B', 'C', 'D'])
print df['A']
print df[['A','B']]
print df[2:2]

Attribute Access
Columns can be selected using the attribute operator '.'.
df = pd.DataFrame(np.random.randn(8, 4), columns = ['A', 'B', 'C', 'D'])

print df.A
Data Ranking
Data Ranking produces ranking for each element in the array of elements. In case of ties, assigns the mean rank.
s = pd.Series(np.random.np.random.randn(5), index=list('abcde'))
s['d'] = s['b'] # so there's a tie
print s.rank()
Applying Aggregations on DataFrame
Calculations with Missing Data
•	When summing data, NA will be treated as Zero
•	If the data are all NA, then the result will be NA
•	df = pd.DataFrame(np.random.randn(5, 3), index=['a', 'c', 'e', 'f',
•	'h'],columns=['one', 'two', 'three'])
•	
•	df = df.reindex(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'])
•	
•	print df['one'].sum()
Fill NA Forward and Backward
Using the concepts of filling discussed in the ReIndexing Chapter we will fill the missing values.
Sr.No	Method & Action
1	pad/fill
Fill methods Forward
2	bfill/backfill
Fill methods Backward
df = pd.DataFrame(np.random.randn(5, 3), index=['a', 'c', 'e', 'f',
'h'],columns=['one', 'two', 'three'])

df = df.reindex(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'])

print df.fillna(method='pad')
print df.fillna(method='backfill')
Drop Missing Values
print df.dropna()
print df.replace({1000:10,2000:60})
Python Pandas - GroupBy
Any groupby operation involves one of the following operations on the original object. They are −
•	Splitting the Object
•	Applying a function
•	Combining the results
In many situations, we split the data into sets and we apply some functionality on each subset. In the apply functionality, we can perform the following operations −
•	Aggregation − computing a summary statistic
•	Transformation − perform some group-specific operation
•	Filtration − discarding the data with some condition
Split Data into Groups
Pandas object can be split into any of their objects. There are multiple ways to split an object like −
•	obj.groupby('key')
•	obj.groupby(['key1','key2'])
•	obj.groupby(key,axis=1)
•	ipl_data = {'Team': ['Riders', 'Riders', 'Devils', 'Devils', 'Kings',
•	   'kings', 'Kings', 'Kings', 'Riders', 'Royals', 'Royals', 'Riders'],
•	   'Rank': [1, 2, 2, 3, 3,4 ,1 ,1,2 , 4,1,2],
•	   'Year': [2014,2015,2014,2015,2014,2015,2016,2017,2016,2014,2015,2017],
•	   'Points':[876,789,863,673,741,812,756,788,694,701,804,690]}
•	df = pd.DataFrame(ipl_data)
•	
•	print df.groupby('Team')
•	print df.groupby('Team').groups
•	print df.groupby(['Team','Year']).groups
•	grouped = df.groupby('Year')
•	print grouped.get_group(2014)
•	print grouped['Points'].agg(np.mean)
•	
•	for name,group in grouped:
•	   print name
•	   print group
•	Attribute Access in Python Pandas
•	grouped = df.groupby('Team')
•	print grouped.agg(np.size)
•	print grouped['Points'].agg([np.sum, np.mean, np.std])
Transformations
Transformation on a group or a column returns an object that is indexed the same size of that is being grouped. Thus, the transform should return a result that is the same size as that of a group chunk.
grouped = df.groupby('Team')
score = lambda x: (x - x.mean()) / x.std()*10
print grouped.transform(score)
Filtration
Filtration filters the data on a defined criteria and returns the subset of data. The filter() function is used to filter the data.
print df.groupby('Team').filter(lambda x: len(x) >= 3)

Python Pandas - Merging/Joining
import pandas as pd
left = pd.DataFrame({
   'id':[1,2,3,4,5],
   'Name': ['Alex', 'Amy', 'Allen', 'Alice', 'Ayoung'],
   'subject_id':['sub1','sub2','sub4','sub6','sub5']})
right = pd.DataFrame(
   {'id':[1,2,3,4,5],
   'Name': ['Billy', 'Brian', 'Bran', 'Bryce', 'Betty'],
   'subject_id':['sub2','sub4','sub3','sub6','sub5']})
print left
print right
Merge Two DataFrames on a Key
print pd.merge(left,right,on='id')
Merge Two DataFrames on Multiple Keys
print pd.merge(left,right,on=['id','subject_id'])
Merge Using 'how' Argument
The how argument to merge specifies how to determine which keys are to be included in the resulting table. If a key combination does not appear in either the left or the right tables, the values in the joined table will be NA.
Here is a summary of the how options and their SQL equivalent names −
Merge Method	SQL Equivalent	Description
left	LEFT OUTER JOIN	Use keys from left object
right	RIGHT OUTER JOIN	Use keys from right object
outer	FULL OUTER JOIN	Use union of keys
inner	INNER JOIN	Use intersection of keys
print pd.merge(left, right, on='subject_id', how='left')
Concatenating Objects
import pandas as pd

one = pd.DataFrame({
   'Name': ['Alex', 'Amy', 'Allen', 'Alice', 'Ayoung'],
   'subject_id':['sub1','sub2','sub4','sub6','sub5'],
   'Marks_scored':[98,90,87,69,78]},
   index=[1,2,3,4,5])

two = pd.DataFrame({
   'Name': ['Billy', 'Brian', 'Bran', 'Bryce', 'Betty'],
   'subject_id':['sub2','sub4','sub3','sub6','sub5'],
   'Marks_scored':[89,80,79,97,88]},
   index=[1,2,3,4,5])
print pd.concat([one,two])
Suppose we wanted to associate specific keys with each of the pieces of the chopped up DataFrame. We can do this by using the keys argument − print pd.concat([one,two],keys=['x','y'])
The index of the resultant is duplicated; each index is repeated.
If the resultant object has to follow its own indexing, set ignore_index to True.
print pd.concat([one,two],keys=['x','y'],ignore_index=True)
If two objects need to be added along axis=1, then the new columns will be appended.
print pd.concat([one,two],axis=1)
Concatenating Using append
A useful shortcut to concat are the append instance methods on Series and DataFrame. These methods actually predated concat. They concatenate along axis=0, namely the index 
print one.append(two)
print one.append([two,one,two])
Time Series
Pandas provide a robust tool for working time with Time series data, especially in the financial sector. While working with time series data, we frequently come across the following −
•	Generating sequence of time
•	Convert the time series to different frequencies
•	print pd.datetime.now()
Create a TimeStamp
print pd.Timestamp('2017-03-01')
print pd.Timestamp(1587687255,unit='s')
Create a Range of Time
print pd.date_range("11:00", "13:30", freq="30min").time
print pd.date_range("11:00", "13:30", freq="H").time
Converting to Timestamps
print pd.to_datetime(pd.Series(['Jul 31, 2009','2010-01-10', None]))
Create a Range of Dates
print pd.date_range('1/1/2011', periods=5)
print pd.date_range('1/1/2011', periods=5,freq='M')
bdate_range
bdate_range() stands for business date ranges. Unlike date_range(), it excludes Saturday and Sunday.
print pd.date_range('1/1/2011', periods=5)
Timedelta
print pd.Timedelta('2 days 2 hours 15 minutes 30 seconds')
print pd.Timedelta(6,unit='h')
print pd.Timedelta(days=2)
Categorical Data
Often in real-time, data includes the text columns, which are repetitive. Features like gender, country, and codes are always repetitive. These are the examples for categorical data.
Categorical variables can take on only a limited, and usually fixed number of possible values. Besides the fixed length, categorical data might have an order but cannot perform numerical operation. Categorical are a Pandas data type
s = pd.Series(["a","b","c","a"], dtype="category")
cat = pd.Categorical(['a', 'b', 'c', 'a', 'b', 'c'])

