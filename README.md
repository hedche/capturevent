### capturevent
- Can be triggered manually by running the Bash script or with a shortcut

##### Workflow
1. After trigger you'll be able to take a custom screenshot (same as `SHIFT` + `CMD` + `4`)
2. OCR will be run on the image to extract text
3. Text sent to locally running custom model
4. Model will output JSON that Apple is happy with to create a calender event

#### Setup
1. Install `ollama`
```
brew install ollama
```
2. Start `ollama` server
```
ollama serve
```
3. Pull Mistral base model (or whatever model you want to use)
```
ollama pull mistral
```
4. Copy the Modelfile
```
cp capturevent.Modelfile ~/.ollama/models/
```
5. Create the `capturevent` model
```
ollama create capturevent -f ~/.ollama/models/capturevent.Modelfile
```
6. Copy custom script to your Raycast scripts directory
```
cp capturevent.sh ~/.raycast/scripts/
```

