#pitch location

pitches <- read.csv('C:/Users/Andrew/Documents/Georgia Tech/ISYE6242/6242data/pitches.csv')
atbats <- read.csv('C:/Users/Andrew/Documents/Georgia Tech/ISYE6242/6242data/atbats.csv')
player_names <- read.csv('C:/Users/Andrew/Documents/Georgia Tech/ISYE6242/6242data/player_names.csv')

library(dplyr)
library(sqldf)
pitches_and_atbats <- pitches %>% left_join(atbats, by= "ab_id")

pitches_and_pitchers <- pitches_and_atbats %>% left_join(player_names, by=c("pitcher_id" = "id"))


max_balls = 3
max_strikes = 2
max_outs = 2
on_1b_vec = c('True','False')


#subset down to lester
lester_pitches <- pitches_and_pitchers %>% filter(first_name == "Jon" & last_name == "Lester") %>%
  filter(zone <= 9) %>% filter(zone >=1) %>% filter(b_count == 0 & s_count == 2 & outs == 2 & on_1b == "False" & on_2b == "False" & on_3b == "False")

full_frame <- data.frame()

for (i in 0:max_balls)
{
  for (j in 0:max_strikes)
  {
    for(k in 0: max_outs)
    {
      for (l in on_1b_vec)
      {
        for (m in on_1b_vec)
        {
          for (q in on_1b_vec)
          {
      lester_pitches <- pitches_and_pitchers %>% filter(first_name == "Jon" & last_name == "Lester") %>%
        filter(zone <= 9) %>% filter(zone >=1) %>% filter(b_count == i & s_count == j & outs == k & on_1b == l & on_2b == m & on_3b == q)
  
      
      
      temp_data_frame <- sqldf("select cast(sum(case when zone=1 then 1 else 0 end)as real)/count(zone) as location_1,
              cast(sum(case when zone=2 then 1 else 0 end)as real)/count(zone) as location_2,
              cast(sum(case when zone=3 then 1 else 0 end)as real)/count(zone) as location_3,
              cast(sum(case when zone=4 then 1 else 0 end)as real)/count(zone) as location_4,
              cast(sum(case when zone=5 then 1 else 0 end)as real)/count(zone) as location_5,
              cast(sum(case when zone=6 then 1 else 0 end)as real)/count(zone) as location_6,
              cast(sum(case when zone=7 then 1 else 0 end)as real)/count(zone) as location_7,
              cast(sum(case when zone=8 then 1 else 0 end)as real)/count(zone) as location_8,
              cast(sum(case when zone=9 then 1 else 0 end)as real)/count(zone) as location_9
             
             
              from lester_pitches")
      
      add_to_it <- data.frame(b_count = i,s_count =j,outs = k, on_1b = l, on_2b =m,on_3b = q)
      
      temp_data_frame <- cbind(temp_data_frame, add_to_it)
      #%>%
       # pivot_wider(names_from = zone, names_prefix = "location_", values_from = freq, values_fn = mean)
      
      
      full_frame <- rbind(temp_data_frame,full_frame)
      
 
          }
        }
        
      }
    }
  }
}

full_frame <- full_frame %>% mutate(runner1 = ifelse(on_1b == "True", 1, 0)) %>%
  mutate(runner2 = ifelse(on_2b == "True", 1,0)) %>%
  mutate(runner3 = ifelse(on_3b == "True", 1, 0))


hist(lester_pitches$zone, nclass=9)
#lester_pitches <- lester_pitches %>% filter(zone == 1)
plot(lester_pitches$y,lester_pitches$x, col=lester_pitches$zone ) 

library(plotly)
plot_ly(data= lester_pitches, y = ~y*-1, x = ~x*-1, color = ~as.factor(zone), colors="Dark2")

hist(lester_pitches$zone, nclass=9)
?hist


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
