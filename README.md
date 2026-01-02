# Political Sentiment Analysis: 2024 U.S. Election

This project analyzes public sentiment on social media (X/Twitter) toward Kamala Harris and Donald Trump during the 5 months leading up to the 2024 U.S. Presidential Election. Combining lexicon-based methods and machine learning, it reveals key differences in how the two candidates were discussed online.

---

## Research Goal

To contextualize the November 2024 election results using sentiment analysis on U.S.-based micro-blogging posts mentioning Harris or Trump.

---

## Methodology

### 1. Data Collection

- **Primary Dataset**: ~18,500 tweets from U.S.-based users (July–November 2024), filtered for opinionated language.
- **Validation Dataset**: 3.4 million tweets pulled from a public GitHub archive to validate trends.

### 2. Lexicon-Based Sentiment Analysis

Used **VADER** and **NRC Emotion Lexicon** to evaluate emotional tone and sentiment intensity.

![Word Frequency](images/harrisemotionmonth.png)

> *In July, Harris was associated with “hope” and “winning”; by October, her posts were linked to “disaster” and “lose”.*

![Word Frequency](images/Trumpemotionmonth.png)

> *Trump saw less severe changes or increases in negative sentiment and benefited from a small increase in positive sentiment*
### 3. Sentiment Trends

Tracked shifts in sentiment over time using machine-learning predictions.

![Emotion Trends](images/canpredtime.png)

- **Harris**: Increasing negativity, peaking in October.
- **Trump**: Gradual shift toward positivity by November.

### 4. Machine Learning Classification

Used a two-stage **Random Forest** model:

- **Model 1**: Classifies the candidate the post is about (Harris, Trump, or Neither).
- **Model 2**: Predicts the sentiment of the post (Positive or Negative).

**Performance:**

| Task              | Accuracy |
|-------------------|----------|
| Candidate Model   | 88%      |
| Sentiment Model   | 75%      |


---

## Key Insights

- Harris faced **more frequent and intense negativity** than Trump.
- Trump experienced **more stable sentiment** and gained positivity closer to election day.
- Emotion spikes aligned with real events (e.g., July assassination attempt on Trump).
- Social media conversations tended to skew **more negative overall**.

---

## Limitations

- Small, hand-labeled dataset.
- Imbalanced classes (more negative than positive posts).
- Lexicon-only approaches (like VADER) underperformed ML models.
- Pretrained BERT models (e.g., for movie reviews or general sentiment) did not adapt well to political tone and language.

---

## Conclusion

The purpose of this project was to contextualize the results of the 2024-Presidential Election by identifying
differences in how social media view the two major candidates. Discrepancies were found in every stage of
the analysis. Throughout the lexicon-based approach, there were differences in the polarity of words used in
tweets about each candidate. While there was high word overlap, the way those words were used to describe
either candidate were not the same. Harris fell victim to sentiments about her entire administration, while
Trump benefited from less direct opinions. Similarly, Harris seemed to be judged on her policy views more
than Trump. Bi-grams identified how views on policy buzzwords in posts mentioning Trump had more
optimistic undertones, while Harris had more negative sentiments. The model analysis contributed to the
theme of negative sentiments increasing for Harris and decreasing for Trump over the five months leading up
to the election. The frequency of negative words and overall sentiment of tweets consistently increased until
reaching an all time high for Harris in October. Comparatively, Trump benefited from an increase positive
sentiment specifically in November. While these findings do not predict voter behavior directly, they give
powerful insights into societal views.
In addition to sentiment analysis findings, this project also identified strong tools for conducting the
analysis. Random forests were found to perform the best out of all tried machine learning algorithms.
Class imbalance had impact on model performance. Lastly, using a lexicon-based approach with a modeling
approach provides strong insights by combining the understandability of word-level sentiment with the
predictive power of machine learning. This dual-method analysis allows for a stronger understanding of how
sentiment is expressed and perceived.


More can be viewed at: [Full Paper](https://scholarship.claremont.edu/cmc_theses/3916/)
