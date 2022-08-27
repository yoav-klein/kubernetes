from flask import Flask
app = Flask(__name__)

@app.route('/web')
def hello_world():
   return '''
<!DOCTYPE html>
<html>
<body>

<h1>My First Heading</h1>
<p>
One day at school, little Jimmy needed to go to the restroom so he raised his hand. The strict substitute teacher asked him to say the full alphabet before she would let him go. "But Miss, I am bursting to go," said Jimmy. "You may go, but after you say the full alphabet." "A-B-C-D-E-F-G-H-I-J-K-L-M-N-O-Q-R-S-T-U-V-W-X-Y-Z," he said. Catching his mistake, the substitute asked, "Jimmy, where is the 'P?'" He answered, "Halfway down my legs, Miss."
</p>

</body>
</html>

   '''

if __name__ == '__main__':
   app.run(host="0.0.0.0")
