//This script is used to detect any sql injection attack by analyzing application log file

var fs = require('fs');
var readline = require('readline');
var stream = require('stream');

var fileName = process.argv.slice(2)[0];

var exit = function(msg){
	console.log("\n\n::::::::::::::::::::::::::::::::::::::\n")
	console.log(msg)
	console.log("\n::::::::::::::::::::::::::::::::::::::")
	process.exit(0);
}

if(!fileName){
	exit("File path not provided");
}

var sqlKeywords = ["select","insert","update","delete","truncate","where","exec"]
var skipKeywords = [
"ef_crossword.swf?input="
]

var keywords = []

if (!fs.existsSync(fileName)) {
    exit("File not found");
}

console.log("File path :",fileName)

var instream = fs.createReadStream(fileName);
var outstream = fs.createWriteStream("output.txt")
var rl = readline.createInterface(instream, outstream);

var isSkipKeywordPresent = function(line){
	for(let skipKeyword of skipKeywords){
		if(line.includes(skipKeyword)){
			return true;
		}
	}
	return false;
}

var isMallicious = function(line) {
	let lowerStr = line.toLowerCase();
	for(let keyword of keywords){
		if(lowerStr.includes(keyword)){
			return !isSkipKeywordPresent(lowerStr);
		}
	}
	return false;
}

var consolidateKeywords = function(){
	sqlKeywords.forEach(function(elm){
		keywords.push(elm+"%20")
	})
}

consolidateKeywords();

rl.on('line', function(line) {
  if(isMallicious(line)){
	  console.log(line)
	  outstream.write(line)
	  outstream.write("\n")
  }
});

rl.on('close', function() {
  outstream.end()
});

outstream.on('finish',function(){
	exit("Log is written in output.txt file")
})
