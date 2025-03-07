<img src="top right corner logo.png" width="100" height="auto" align="right"/>
# addcomment
Document an analysis process through comments.

## Syntax

[`dataout = addcomments(data,comment)`](#s1)

## Description
`dataout = addcomments(data)` <a name="s1"></a> adds a comment to a drEEMdataset that describes an observation, justifies a decision, or documents any other kind of process. The comment field will be stored in the document's history and can be retreived with [`viewistory`](viewhistory.hmtl) and [`displayhistory`](displayhistory.hmtl) and will be exported with [`exportresults`](exportresults.hmtl) and [`export2zip`](export2zip.hmtl)

## Examples
	samples=tbx.addcomment(samples,'Smart thing to say here.')

## Input arguments
<details>
    <summary><b>`data` - dataset to add comment to</b></summary>
    <i>drEEMdataset class</i>
        
A dataset of the class `drEEMdataset` that passes the validation function `data.validate(data)`. 
</details>

<details open>
    <summary><b>`comment` - descriptive text</b></summary>
    <i>text of the class string or char</i>
        
A text that describes some observation, a concern, a result, a course of action or anything else worthy of documenting.

</details>

<!---
## Name-Value arguments
-->
