#pitch location

pitches <- read.csv('C:/Users/Andrew/Documents/Georgia Tech/ISYE6242/6242data/pitches.csv')
atbats <- read.csv('C:/Users/Andrew/Documents/Georgia Tech/ISYE6242/6242data/atbats.csv')
player_names <- read.csv('C:/Users/Andrew/Documents/Georgia Tech/ISYE6242/6242data/player_names.csv')

library(dplyr)
pitches_and_atbats <- pitches %>% left_join(atbats, by= "ab_id")

pitches_and_pitchers <- pitches_and_atbats %>% left_join(player_names, by=c("pitcher_id" = "id"))

#subset down to lester
lester_pitches <- pitches_and_pitchers %>% filter(first_name == "Jon" & last_name == "Lester") %>%
  filter(zone <= 9)

#lester_pitches <- lester_pitches %>% filter(zone == 1)
plot(lester_pitches$y,lester_pitches$x, col=lester_pitches$zone )

library(plotly)
plot_ly(data= lester_pitches, y = ~y*-1, x = ~x*-1, color = ~as.factor(zone), colors="Dark2")


#text(lester_pitches$y~lester_pitches$x, labels=lester_pitches$zone, cex=0.9, font=2)

strike_zones <- data.frame(
  x1 = rep(-1.5:0.5, each = 3),
  x2 = rep(-0.5:1.5, each = 3),
  y1 = rep(1.5:3.5, 3),
  y2 = rep(2.5:4.5, 3),
  z = factor(c(7, 4, 1, 8, 5, 2, 9, 6, 3))
)
strike_zones$labcol <- c("red","red","yellow","orange","orange","red","yellow","red","red")

ggplot() +
xlim(-3, 3) + xlab("") +
  ylim(0, 6) + ylab("") +
  geom_rect(data = strike_zones,
            aes(xmin = x1, xmax = x2, ymin = y2, ymax = y1), fill = strike_zones$labcol, color = "grey20") +
  geom_text(data = strike_zones,
            aes(x = x1 + (x2 - x1)/2, y = y1 + (y2 - y1)/2, label = z),
            size = 7, fontface = 2, color = I("grey20")) +
  theme_bw() + theme(legend.position = "none")



lester_pitches %>%
  group_by(zone) %>%
  summarise(n = n()) %>%
  mutate(freq = n / sum(n))
